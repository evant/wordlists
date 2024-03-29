require 'sinatra/base' 
require 'sinatra/cookies'
require 'haml'
require 'sass'
require 'pagify/data_mapper'

#set up database
require_relative 'db_config'
heroku = !!ENV['HEROKU_TYPE']
Database.set(heroku ? :production : :development)

#make pagify happy
class Object
  def blank?
    respond_to?(:empty?) ? empty? : !self
  end
end

require_relative 'presenters/category_presenter'
require_relative 'presenters/word_presenter'

class WordLists < Sinatra::Base
  helpers Sinatra::Cookies

  helpers do
    require 'pagify/helper/html'

    def h_uri(str)
      URI.escape(str.to_s, '/?&;')
    end 

    def h(str)
      escape_html(str.to_s)
    end

    def flash(name)
      haml "flash/#{name}".to_sym if name
    end

    def nav_link(path)
      {href: url(path), :class => ('current' if @path == path)}
    end

    def category_threashold
      Category.vote_threashold
    end

    def word_threashold
      Word.vote_threashold
    end
  end

  before do
    @path = request.path_info
  end

  get '/about' do
    haml :about
  end

  get('/:style.css') { |style| scss style.to_sym }

  get '/upload' do
    @categories = Category.confirmed
    @selected_category = params[:category]

    haml :upload
  end

  post '/upload' do
    @categories = Category.confirmed

    input = ""
    input << params[:file][:tempfile].read if params[:file]
    input << params[:words] if params[:words]

    if input.strip.empty?
      @flash = :upload_empty
    else

      @category = Category.confirmed.first(:name => params[:category])    

      user = User.from_cookie_or_ip(cookies, request.ip)
      submission = Submission.new(words_from_string(input))

      if submission.submit_new_words_to(@category, :by => user)
        @word_count = submission.new_word_count
        @flash = if @word_count == 0
                   :upload_no_new_words
                 else
                   :upload_sucess
                 end
      else
        @flash = :upload_error
      end
    end

    @selected_category = params[:category]

    haml :upload
  end

  def words_from_string(input)
    input.split(/[,\n]/).map(&:strip).reject(&:empty?)
  end

  get '/category_vote' do
    @categories = Category.suggested

    haml :category_vote
  end

  post '/category_vote' do

    @categories = Category.suggested

    category_name = (params[:category] || '').strip

    if category_name.empty?
      @flash = :category_empty
    else
      @category = Category.first_or_new(:name => category_name)  
      if Category.confirmed.count(:name => category_name) > 0 
        @flash = :category_already_exists
      else
        user = User.from_cookie_or_ip(cookies, request.ip)

        if CategoryUser.count(:category => @category, :user => user) > 0
          @flash = :category_already_submitted
        else
          @category.users << user
          @category.add_vote

          if @category.save
            @flash = :category_added
          else
            @flash = :category_error
          end
        end
      end
    end

    haml :category_vote
  end

  get '/' do
    @categories = Category.confirmed.all(:order => [:name.asc])

    haml :word_lists
  end

  [:txt, :xml, :json].each do |format|
    get "/.#{format}" do
      @categories = Category.confirmed.all(:order => [:name.asc])

      content_type format
      CategoryPresenter.new(@categories).send(format)
    end
  end

  [:txt, :xml, :json].each do |format|
    get "/category/:category_name.#{format}" do |category_name|
      @category = Category.first(:name => category_name)
      @words = @category.confirmed_words

      content_type format
      WordPresenter.new(@words).send(format)
    end
  end

  get '/category/:category_name' do |category_name|
    @category = Category.first(:name => category_name)
    @page = params[:page].to_i
    @words = @category.words.all(:order => [:votes.desc, :name.asc]).pagify(:page => @page, :per_page => 50)
    @word_count = @category.words.count

    haml :word_list
  end
end
