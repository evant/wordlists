module Voteable
  def self.included(base)
    base.class_eval do
      property :votes, Integer, :default => 0, :writer => :protected
    end
  end

   def add_vote
    self.votes += 1
  end
end
