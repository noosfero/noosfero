# for some unknown reason, if this is named SuppliersPlugin::Product then
# cycle.products will go to an infinite loop
class SuppliersPlugin::BaseProduct < Product

  attr_accessible :default_margin_percentage, :margin_percentage, :default_unit, :unit_detail,
    :supplier_product_attributes

  accepts_nested_attributes_for :supplier_product

  default_scope include: [
    # from_products is required for products.available
    :from_products,
    # FIXME: move use cases to a scope called 'includes_for_links'
    {
      suppliers: [{ profile: [:domains, {environment: :domains}] }]
    },
    {
      profile: [:domains, {environment: :domains}]
    }
  ]

  # if abstract_class is true then it will trigger https://github.com/rails/rails/issues/20871
  #self.abstract_class = true

  settings_items :minimum_selleable, type: Float, default: nil
  settings_items :margin_percentage, type: Float, default: nil
  settings_items :quantity, type: Float, default: nil
  settings_items :unit_detail, type: String, default: nil

  CORE_DEFAULT_ATTRIBUTES = [
    :name, :description, :price, :unit_id, :product_category_id, :image_id,
  ]
  DEFAULT_ATTRIBUTES = CORE_DEFAULT_ATTRIBUTES + [
    :margin_percentage, :stored, :minimum_selleable, :unit_detail,
  ]

  extend DefaultDelegate::ClassMethods
  default_delegate_setting :name, to: :supplier_product
  default_delegate_setting :description, to: :supplier_product

  default_delegate_setting :qualifiers, to: :supplier_product
  default_delegate :product_qualifiers, default_setting: :default_qualifiers, to: :supplier_product

  default_delegate_setting :product_category, to: :supplier_product
  default_delegate :product_category_id, default_setting: :default_product_category, to: :supplier_product

  default_delegate_setting :image, to: :supplier_product, prefix: :_default
  default_delegate :image_id, default_setting: :_default_image, to: :supplier_product

  default_delegate_setting :unit, to: :supplier_product
  default_delegate :unit_id, default_setting: :default_unit, to: :supplier_product

  default_delegate_setting :margin_percentage, to: :profile,
    default_if: -> { self.own_margin_percentage.blank? or self.own_margin_percentage.zero? }
  default_delegate :price, default_setting: :default_margin_percentage, default_if: :equal?,
    to: -> { self.supplier_product.price_with_discount if self.supplier_product }

  default_delegate :unit_detail, default_setting: :default_unit, to: :supplier_product
  default_delegate_setting :minimum_selleable, to: :supplier_product

  extend CurrencyHelper::ClassMethods
  has_currency :own_price
  has_currency :original_price
  has_number_with_locale :minimum_selleable
  has_number_with_locale :own_minimum_selleable
  has_number_with_locale :original_minimum_selleable
  has_number_with_locale :quantity
  has_number_with_locale :margin_percentage
  has_number_with_locale :own_margin_percentage
  has_number_with_locale :original_margin_percentage

  def self.default_product_category environment
    ProductCategory.top_level_for(environment).order('name ASC').first
  end
  def self.default_unit
    Unit.new(singular: I18n.t('suppliers_plugin.models.product.unit'), plural: I18n.t('suppliers_plugin.models.product.units'))
  end

  # override SuppliersPlugin::BaseProduct
  def self.search_scope scope, params
    scope = scope.from_supplier_id params[:supplier_id] if params[:supplier_id].present?
    scope = scope.with_available(if params[:available] == 'true' then true else false end) if params[:available].present?
    scope = scope.fp_name_like params[:name] if params[:name].present?
    scope = scope.fp_with_product_category_id params[:category_id] if params[:category_id].present?
    scope
  end

  def self.orphans_ids
    # FIXME: need references from rails4 to do it without raw query
    result = self.connection.execute <<-SQL
SELECT products.id FROM products
LEFT OUTER JOIN suppliers_plugin_source_products ON suppliers_plugin_source_products.to_product_id = products.id
LEFT OUTER JOIN products from_products_products ON from_products_products.id = suppliers_plugin_source_products.from_product_id
WHERE products.type IN (#{(self.descendants << self).map{ |d| "'#{d}'" }.join(',')})
GROUP BY products.id HAVING count(from_products_products.id) = 0;
SQL
    result.values
  end

  def self.archive_orphans
    self.where(id: self.orphans_ids).find_each batch_size: 50 do |product|
      # need full save to trigger search index
      product.update archived: true
    end
  end

  def buy_price
    self.supplier_products.inject(0){ |sum, p| sum += p.price || 0 }
  end
  def buy_unit
    #TODO: handle multiple products
    (self.supplier_product.unit rescue nil) || self.class.default_unit
  end

  def available
    self[:available]
  end

  def available_with_supplier
    return self.available_without_supplier unless self.supplier
    self.available_without_supplier and self.supplier.active rescue false
  end
  def chained_available
    return self.available_without_supplier unless self.supplier_product
    self.available_without_supplier and self.supplier_product.available and self.supplier.active rescue false
  end
  alias_method_chain :available, :supplier

  def dependent?
    self.from_products.length >= 1
  end
  def orphan?
    !self.dependent?
  end

  def minimum_selleable
    self[:minimum_selleable] || 0.1
  end

  def price_with_margins base_price = nil, margin_source = nil
    margin_source ||= self
    margin_percentage = margin_source.margin_percentage
    margin_percentage ||= self.profile.margin_percentage if self.profile

    base_price ||= 0
    price = if margin_percentage and not base_price.zero?
      base_price.to_f + (margin_percentage.to_f / 100) * base_price.to_f
    else
      self.price_with_default
    end

    price
  end

  def price_without_margins
    self[:price] / (1 + self.margin_percentage/100)
  end

  # FIXME: move to core
  # just in case the from_products is nil
  def product_category_with_default
    self.product_category_without_default or self.class.default_product_category(self.environment)
  end
  def product_category_id_with_default
    self.product_category_id_without_default or self.product_category_with_default.id
  end
  alias_method_chain :product_category, :default
  alias_method_chain :product_category_id, :default

  # FIXME: move to core
  def unit_with_default
    self.unit_without_default or self.class.default_unit
  end
  alias_method_chain :unit, :default

  # FIXME: move to core
  def archive
    self.update! archived: true
  end
  def unarchive
    self.update! archived: false
  end

  protected

  def validate_uniqueness_of_column_name?
    false
  end

  # overhide Product's after_create callback to avoid infinite loop
  def distribute_to_consumers
  end

end
