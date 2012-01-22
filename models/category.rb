require_relative 'voteable'

CATEGORY_THREASHOLD = 0

class Category
  include DataMapper::Resource

  property :id, Serial
  property :name, String, :required => true
  
  include Voteable
  has n, :words

  def self.confirmed
    Category.all(:votes.gte => CATEGORY_THREASHOLD)
  end

  def self.suggested
    Category.all(:votes.lt => CATEGORY_THREASHOLD)
  end

  def add_words(words)
    words.each do |word_name|
      word = self.words.first_or_new(:name => word_name)
      word.add_vote
    end
    self.save
  end

  def to_s
    name
  end  
end
