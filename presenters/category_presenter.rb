require 'builder'
require 'json'

class CategoryPresenter
  def initialize(category)
    @category = category
  end

  def txt
    @category.confirmed_words.join("\n")
  end

  def xml
    words =@category.confirmed_words

    result = ""
    xml = Builder::XmlMarkup.new(:target => result)
    xml.instruct!

    xml.word_list do
      xml.category @category
      xml.words do
        words.each do |word| 
          xml.word word
        end
      end
    end

    result
  end

  def json
    words =@category.confirmed_words

    { 
      category: @category.to_s,
      words: words.map(&:to_s)
    }.to_json
  end
end
