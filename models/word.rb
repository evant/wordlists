require_relative 'voteable'

class Word
  include DataMapper::Resource

  property :id, Serial
  property :name, String, :required => true

  belongs_to :category
  has n, :users, :through => Resource, :constraint => :destroy

  include Voteable
  vote_threashold 2

  def to_s
    name
  end
end
