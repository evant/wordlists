require 'builder'
require 'json'

class CategoryPresenter
  def initialize(categories)
    @categories = categories
  end

  def txt
    @categories.join("\n")
  end

  def xml
    result = ""
    xml = Builder::XmlMarkup.new(:target => result)
    xml.instruct!

    xml.categories do
      @categories.each do |category|
        xml.category({href: "/category/#{URI.escape(category.to_s, '/?&;')}.xml"}, category)
      end  
    end
  end

  def json
    {
      categories: @categories.map { |category|
      {
        name: category.to_s, 
        href: "/category/#{URI.escape(category.to_s, '/?&;')}.json"
      }}
    }.to_json
  end
end
