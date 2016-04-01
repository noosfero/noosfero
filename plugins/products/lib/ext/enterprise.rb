require_dependency 'enterprise'

class Enterprise

  attr_accessible :products_per_catalog_page

  settings_items :products_per_catalog_page, type: :integer, default: 6
  alias_method :products_per_catalog_page_before_type_cast, :products_per_catalog_page
  validates_numericality_of :products_per_catalog_page, allow_nil: true, greater_than: 0

  def highlighted_products_with_image(options = {})
    Product.where(highlighted: true).joins(:image)
  end

  def default_set_of_blocks
    links = [
      {name: _("Enterprises's profile"), address: '/profile/{profile}', icon: 'ok'},
      {name: _('Blog'), address: '/{profile}/blog', icon: 'edit'},
      {name: _('Products'), address: '/profile/{profile}/plugin/products/catalog', icon: 'new'},
    ]
    blocks = [
      [MainBlock.new],
      [ ProfileImageBlock.new,
        LinkListBlock.new(links: links),
        ProductCategoriesBlock.new
      ],
      [LocationBlock.new]
    ]
    blocks[2].unshift ProductsBlock.new
    blocks
  end

  def catalog_url
    {profile: identifier, controller: 'products_plugin/catalog'}
  end

  def create_product?
    true
  end

end
