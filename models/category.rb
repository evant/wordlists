require_relative 'voteable'

class Category
  include DataMapper::Resource
  property :id, Serial
  property :name, String, :required => true
  
  has n, :words

  include Voteable
  vote_threashold 20

  def add_word(name)
    word = self.words.first_or_new(:name => name)
    word.add_vote
    word.save
  end

  def to_s
    name
  end  
end
