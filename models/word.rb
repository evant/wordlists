require_relative 'voteable'

class Word
  include DataMapper::Resource
  include Voteable

  vote_threashold = 0

  property :id, Serial
  property :name, String, :required => true

  belongs_to :category

  def to_s
    name
  end
end
