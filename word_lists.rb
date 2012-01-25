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

require_relative 'presenters/categories_presenter'

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

    haml :upload
  end

  post '/upload' do
    @categories = Category.confirmed

    input = ""
    input << params[:file][:tempfile].read if params[:file]
    input << params[:words] if params[:words]

    if input.empty?
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
      if Category.confirmed.count(:name => category_name) > 0 
        @flash = :category_already_exists
      else
        @category = Category.first_or_new(:name => category_name)  
        @category.add_vote

        if @category.save
          @flash = :category_added
        else
          @flash = :category_error
        end
      end
    end

    haml :category_vote
  end

  get '/' do
    @categories = Category.confirmed

    haml :word_lists
  end

  get '/view/:category_name' do |category_name|
    @category = Category.first(:name => category_name)
    @page = params[:page].to_i
    @words = @category.words.all(:order => [:name.asc]).pagify(:page => @page, :per_page => 50)
    
    haml :word_list
  end

  get '/download/:category_name' do |category_name|
    @category = Category.first(:name => category_name)

    content_type :text
    CategoriesPresenter.new(Category).text
  end
end
