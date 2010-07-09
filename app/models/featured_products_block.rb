class FeaturedProductsBlock < Block

  settings_items :product_ids, :type => Array, :default => []
  settings_items :groups_of, :type => :integer, :default => 3
  settings_items :speed, :type => :integer, :default => 1000
  settings_items :reflect, :type => :boolean, :default => true

  before_save do |block|
    if block.owner.kind_of?(Environment) && block.product_ids.blank?
      seed = block.owner.products.count
      block.product_ids = block.owner.highlighted_products_with_image(:offset => (rand(seed) % (seed - block.groups_of * 3)), :limit => block.groups_of * 3).map(&:id)
    end
    block.groups_of = block.groups_of.to_i
  end

  def self.description
    _('Featured Products')
  end

  def products
    Product.find(self.product_ids) || []
  end

  def products_for_selection
    self.owner.highlighted_products_with_image
  end

  def content
    block = self
    lambda do
      render :file => 'blocks/featured_products', :locals => { :block => block }
    end
  end

end
