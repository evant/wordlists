require_relative 'voteable'

class Category
  include DataMapper::Resource
  property :id, Serial
  property :name, String, :required => true
  
  has n, :words
  has n, :users, :through => Resource

  include Voteable
  vote_threashold 10

  def confirmed_words
    words.confirmed.all(:order => [:name.asc])
  end

  def add_word(name)
    word = self.words.first_or_new(:name => name)
    word.add_vote
    word.save
  end

  def to_s
    name
  end  
end
