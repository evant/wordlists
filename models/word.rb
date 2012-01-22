require_relative 'voteable'

class Word
  include DataMapper::Resource

  property :id, Serial
  property :name, String, :required => true

  include Voteable
  belongs_to :category

  def to_s
    name
  end
end
