class CategoriesPresenter
  def initialize(categories)
    @categories = categories
  end

  def view
    @categories.order_by_votes
  end

  def text
    @categories.confirmed.words.alphabetical.join("\n")
  end
end
