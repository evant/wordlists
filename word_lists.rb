require 'sinatra/base' 
require 'haml'

#set up database
require_relative 'db_config'
heroku = !!ENV['HEROKU_TYPE']
Database.set(heroku ? :production : :development)

class WordLists < Sinatra::Base
  helpers do
    def h_uri(str)
      URI.escape(str.to_s, '/?&;')
    end 

    def h(str)
      escape_html(str.to_s)
    end
  end

  get '/' do
    haml :index
  end

  get '/upload' do
    @categories = Category.confirmed

    haml :upload
  end

  post '/upload' do
    @categories = Category.confirmed

    input = ""
    input << params[:file][:tempfile].read if params[:file]
    input << params[:words] if params[:words]

    words = words_from_string(input)

    @category = Category.first(:name => params[:category])    
    @category.add_words(words_from_string(input))

    @word_count = words.size
    @flash = true

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
    
    haml :word_list
  end

  get '/word_lists/download/:category_name' do |category_name|
    @category = Category.first(:name => category_name)

    content_type :text
    @category.words.join("\n")
  end
end
