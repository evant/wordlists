require 'sinatra/base' 
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

class WordLists < Sinatra::Base
  helpers do
    require 'pagify/helper/html'

    def h_uri(str)
      URI.escape(str.to_s, '/?&;')
    end 

    def h(str)
      escape_html(str.to_s)
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
      @error = true
    else

      @words = words_from_string(input)
      @category = Category.first(:name => params[:category])    

      @user = if cookie[:user]
                User.first(:id => cookie[:user].to_i)
              else
                User.new
              end

      @words.each do |word|
        unless @user.words.include? word
          @category.add_word(word)
          @user.words << word
        end
      end

      @user.save
      @category.save

      @flash = true
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

    @category = Category.first_or_new(:name => params[:category])  

    if Category.confirmed.include? @category
      @error = true
    else
      @category.add_vote
    end
    
    @category.save

    haml :category_vote
  end

  get '/' do
    @categories = Category.confirmed

    haml :word_lists
  end

  get '/view/:category_name' do |category_name|
    @category = Category.first(:name => category_name)
    @page = params[:page].to_i
    @words = @category.show_words.pagify(:page => @page, :per_page => 50)
    
    haml :word_list
  end

  get '/download/:category_name' do |category_name|
    @category = Category.first(:name => category_name)

    content_type :text
    @category.download_words
  end
end
