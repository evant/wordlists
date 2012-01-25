class CategoriesPresenter
  def initialize(categories)
    @categories = categories
  end

  def text
    @categories.confirmed.words.all(:order => [:votes.desc, :name.asc]).join("\n")
  end
end
