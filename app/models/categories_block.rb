class CategoriesBlock < Block

  settings_items :category_types, :type => Array, :default => []

  attr_accessible :category_types

  def self.description
    _("Categories Menu")
  end

  def default_title
    _("Categories Menu")
  end

  def help
    _('This block presents the categories like a web site menu.')
  end

  def selected_categories
    Category.top_level_for(self.owner).from_types(self.category_types)
  end

  def self.expire_on
      { :profile => [], :environment => [:category] }
  end
end
