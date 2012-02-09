require 'builder'
require 'json'

class WordPresenter
  def initialize(words)
    @words = words
  end

  def txt
    @words.join("\n")
  end

  def xml
    result = ""
    xml = Builder::XmlMarkup.new(:target => result)
    xml.instruct!

    xml.words do
      @words.each do |word| 
        xml.word word
      end
    end

    result
  end

  def json
    { words: @words.map(&:to_s) }.to_json
  end
end
