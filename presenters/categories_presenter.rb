class CategoriesPresenter
  def initialize(categories)
    @categories = categories
  end

  def text
    @categories.confirmed.words.confirmed.all(:order => [:name.asc]).join("\n")
  end
end
