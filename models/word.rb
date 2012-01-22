class Word
  include DataMapper::Resource

  property :id, Serial
  property :name, String, :required => true, :accessor => :private
  property :votes, Integer, :default => 0, :writer => :private

  def add_vote
    votes += 1
  end

  def to_s
    name
  end
end
