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
  end

  before do
    @path = request.path_info
  end

  get '/' do
    haml :index
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
      words = words_from_string(input)

      @category = Category.first(:name => params[:category])    
      @category.add_words(words_from_string(input))

      @word_count = words.size
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
    @category = Category.first_or_new(:name => params[:category])  
    @category.add_vote
    
    put "Unable to save: #{@category}" unless @category.save

    redirect url('/category_vote')
  end

  get '/word_lists' do
    @categories = Category.confirmed

    haml :word_lists
  end

  get '/word_lists/view/:category_name' do |category_name|
    @category = Category.first(:name => category_name)
    @page = params[:page].to_i
    @words = @category.show_words.pagify(:page => @page, :per_page => 50)
    
    haml :word_list
  end

  get '/word_lists/download/:category_name' do |category_name|
    @category = Category.first(:name => category_name)

    content_type :text
    @category.download_words
  end
end
