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
      if @categories.nil? or @categories.length == 0
        categories = ProductCategory.on_level().order(:name)
        if @categories and @categories.length == 0
          notice = _('There are no sub-categories for %s') % @category.name
        end
      else
        categories = @categories
      end
      render :file => 'blocks/product_categories',
             :locals => {
               :profile => profile,
               :categories => categories,
               :notice => notice
             }
    end
  end

  def visible?(context=nil)
    box.environment.enabled?('products_for_enterprises')
  end

end
