class Submission
  def initialize(word_list)
    @word_list = word_list
  end

  def submit_new_words_to(category, options = {})
    @word_count = 0

    user = options[:by]
    @word_list.each do |word|
      word = category.words.first_or_new(:name => word)

      next if UserWord.count(:word => word, :user => user) > 0

      word.users << user
      word.add_vote
      word.save
      @word_count += 1
    end
  end

  def new_word_count
    @word_count
  end
end
