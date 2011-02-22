class CategoriesBlock < Block

  CATEGORY_TYPES = {
    _('Generic category') => nil,
    _('Region') => 'Region',
    _('Product') => 'ProductCategory'
  }

  settings_items :category_types, :type => Array, :default => []

  def self.description
    _("Categories Menu")
  end

  def default_title
    _("Categories Menu")
  end

  def help
    _('This block presents the categories like a web site menu.')
  end

  def available_category_types
    CATEGORY_TYPES
  end

  def selected_categories
    Category.top_level_for(self.owner).from_types(self.category_types)
  end

  def content
    block = self
    lambda do
      render :file => 'blocks/categories', :locals => { :block => block }
    end
  end

end
