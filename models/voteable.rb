module Voteable
  def self.included(base)
    base.extend ClassMethods
    base.class_eval do
      property :votes, Integer, :default => 0
    end
  end

  def add_vote
    self.votes += 1
  end

  module ClassMethods
    attr_writer :vote_threashold

    def vote_threashold(value=nil)
      if value.nil?
        @vote_threashold ||= 0
      else
        @vote_threashold = value
      end
    end

    def confirmed
      all(:votes.gte => vote_threashold)
    end

    def suggested
      all(:votes.lt => vote_threashold)
    end
  end
end
