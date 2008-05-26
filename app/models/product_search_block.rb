class ProductSearchBlock < Block

  def self.description
    _('A block to search products.')
  end

  def self.title
    _('Product search')
  end

  def content
    block_title(title)
  end

end
