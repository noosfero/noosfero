class OrdersCyclePlugin::OfferedProduct < SuppliersPlugin::BaseProduct

  # FIXME: WORKAROUND for https://github.com/rails/rails/issues/6663
  # OrdersCyclePlugin::Sale.find(3697).cycle.suppliers returns empty without this
  def self.finder_needs_type_condition?
    false
  end

  has_many :cycle_products, foreign_key: :product_id, class_name: 'OrdersCyclePlugin::CycleProduct'
  has_one  :cycle_product,  foreign_key: :product_id, class_name: 'OrdersCyclePlugin::CycleProduct'
  has_many :cycles, through: :cycle_products
  has_one  :cycle,  through: :cycle_product

  # OVERRIDE suppliers/lib/ext/product.rb
  # for products in cycle, these are the products of the suppliers:
  #   p in cycle -> p distributed -> p from supplier
  # So, sources_supplier_products is the same as sources_from_2x_products
  has_many :sources_supplier_products, through: :from_products, source: :sources_from_products
  has_one  :sources_supplier_product,  through: :from_product,  source: :sources_from_product
  # necessary only due to the override of sources_supplier_products, as rails somehow caches the old reference
  # copied from suppliers/lib/ext/product
  has_many :supplier_products, through: :sources_supplier_products, source: :from_product, order: 'id ASC'
  has_one  :supplier_product,  through: :sources_supplier_product,  source: :from_product, order: 'id ASC', autosave: true
  has_many :suppliers, through: :sources_supplier_products, uniq: true, order: 'id ASC'
  has_one  :supplier,  through: :sources_supplier_product, order: 'id ASC'

  instance_exec &OrdersPlugin::Item::DefineTotals
  extend CurrencyHelper::ClassMethods
  has_currency :buy_price

  # test this before use!
  #validates_presence_of :cycle

  # remove on rails4
  scope :with_price, conditions: 'products.price > 0'
  scope :with_product_category_id, lambda { |id| { conditions: {product_category_id: id} } }
  def self.search_scope scope, params
    scope = scope.from_supplier_id params[:supplier_id] if params[:supplier_id].present?
    scope = scope.with_available(if params[:available] == 'true' then true else false end) if params[:available].present?
    scope = scope.name_like params[:name] if params[:name].present?
    scope = scope.with_product_category_id params[:category_id] if params[:category_id].present?
    scope
  end

  def self.create_from product, cycle
    op = self.new

    product.attributes.except('id').each{ |a,v| op.send "#{a}=", v }
    op.freeze_default_attributes product
    op.profile = product.profile
    op.type = self.name

    op.from_products << product
    cycle.products << op if cycle

    op
  end

  # always recalculate in case something has changed
  def margin_percentage
    return self['margin_percentage'] if price.nil? or buy_price.nil? or price.zero? or buy_price.zero?
    ((price / buy_price) - 1) * 100
  end
  def margin_percentage= value
    self['margin_percentage'] = value
    self.price = self.price_with_margins buy_price
  end

  def sell_unit
    self.unit || self.class.default_unit
  end

  # reimplement to don't destroy this, keeping history in cycles
  # offered products copy attributes
  def dependent?
    false
  end

  # cycle products freezes properties and don't use the original
  DEFAULT_ATTRIBUTES.each do |a|
    define_method "default_#{a}" do
      nil
    end
  end

  FROOZEN_DEFAULT_ATTRIBUTES = DEFAULT_ATTRIBUTES
  def freeze_default_attributes from_product
    FROOZEN_DEFAULT_ATTRIBUTES.each do |attr|
      self[attr] = from_product.send(attr) if from_product[attr] or from_product.respond_to? attr
    end
  end

  def solr_index?
    false
  end

  protected

  after_update :sync_ordered
  def sync_ordered
    return unless self.price_changed?
    self.items.each do |item|
      item.calculate_prices self.price
      item.save!
    end
  end

end
