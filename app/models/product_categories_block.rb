class ProductCategoriesBlock < Block

  def self.description
    _('Product category menu')
  end

  # the title of the block. Probably will be overriden in subclasses.
  def default_title
    _('Catalog')
  end

  def help
    _('Helps to filter the products catalog.')
  end

  def content(args={})
    profile = owner
    lambda do
      categories = @categories || ProductCategory.on_level().order(:name)
      render :file => 'blocks/product_categories', :locals => {:profile => profile, :categories => categories}
    end
  end

end
