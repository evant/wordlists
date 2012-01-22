require 'sinatra/base' 
require 'haml'

#set up database
require_relative 'db_config'
heroku = !!ENV['HEROKU_TYPE']
Database.set(heroku ? :production : :development)

class WordLists < Sinatra::Base
  get '/' do
    haml :index
  end

  get '/upload' do
    @categories = Category.all

    haml :upload
  end

  get '/wordlists' do
    @categories = Category.all

    haml :wordlists
  end

  get '/wordlists/view/:category_name' do |category_name|
    @category = Category.find(name: category_name)
    
    haml :wordlist
  end

  get '/wordlists/download/:category_name' do |category_name|
    @category = Category.find(name: category_name)

    content_type :text
    @category.words.join("\n")
  end
end
