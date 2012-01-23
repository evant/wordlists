require_relative 'voteable'

class Category
  include DataMapper::Resource
  include Voteable

  vote_threashold 20

  property :id, Serial
  property :name, String, :required => true
  
  has n, :words

  def add_words(words)
    words.each do |word_name|
      word = self.words.first_or_new(:name => word_name)
      word.add_vote
    end
    self.save
  end

  def show_words
    words.all(:order => [:votes.desc, :name.asc])
  end

  def download_words
    words.confirmed.all(:order => [:name.asc]).join("\n")
  end

  def to_s
    name
  end  
end
