require_dependency 'product'

# FIXME: The lines bellow should be on the core
class Product

  extend CurrencyHelper::ClassMethods
  has_currency :price
  has_currency :discount

  scope :available, conditions: {available: true}
  scope :unavailable, conditions: ['products.available <> true']
  scope :archived, conditions: {archived: true}
  scope :unarchived, conditions: ['products.archived <> true']

  scope :with_available, lambda { |available| where available: available }
  scope :with_price, conditions: 'products.price > 0'
  scope :with_product_category_id, lambda { |id| { conditions: {product_category_id: id} } }

  # FIXME: transliterate input and name column
  scope :name_like, lambda { |name| { conditions: ["LOWER(products.name) LIKE ?", "%#{name}%"] } }

  scope :by_profile, lambda { |profile| { conditions: {profile_id: profile.id} } }
  scope :by_profile_id, lambda { |profile_id| { conditions: {profile_id: profile_id} } }

  def self.product_categories_of products
    ProductCategory.find products.collect(&:product_category_id).compact.select{ |id| not id.zero? }
  end

  attr_accessible :external_id
  settings_items :external_id, type: String, default: nil

  # should be on core, used by SuppliersPlugin::Import
  attr_accessible :price_details

end

class Product

  attr_accessible :from_products, :supplier_id, :supplier

  has_many :sources_from_products, foreign_key: :to_product_id, class_name: 'SuppliersPlugin::SourceProduct', dependent: :destroy
  has_one  :sources_from_product,  foreign_key: :to_product_id, class_name: 'SuppliersPlugin::SourceProduct'
  has_many :sources_to_products, foreign_key: :from_product_id, class_name: 'SuppliersPlugin::SourceProduct', dependent: :destroy
  has_one  :sources_to_product,  foreign_key: :from_product_id, class_name: 'SuppliersPlugin::SourceProduct'
  has_many :to_products, through: :sources_to_products, order: 'id ASC'
  has_one  :to_product,  through: :sources_to_product,  order: 'id ASC', autosave: true
  has_many :from_products, through: :sources_from_products, order: 'id ASC'
  has_one  :from_product,  through: :sources_from_product,  order: 'id ASC', autosave: true

  has_many :sources_from_2x_products, through: :from_products, source: :sources_from_products
  has_one  :sources_from_2x_product,  through: :from_product,  source: :sources_from_product
  has_many :sources_to_2x_products,   through: :to_products,   source: :sources_to_products
  has_one  :sources_to_2x_product,    through: :to_product,    source: :sources_to_product
  has_many :from_2x_products, through: :sources_from_2x_products, source: :from_product
  has_one  :from_2x_product,  through: :sources_from_2x_product,  source: :from_product
  has_many :to_2x_products,   through: :sources_to_2x_products,   source: :to_product
  has_one  :to_2x_product,    through: :sources_to_2x_product,    source: :to_product

  # semantic alias for supplier_from_product(s)
  has_many :sources_supplier_products, foreign_key: :to_product_id, class_name: 'SuppliersPlugin::SourceProduct'
  has_one  :sources_supplier_product,  foreign_key: :to_product_id, class_name: 'SuppliersPlugin::SourceProduct'
  has_many :supplier_products, through: :sources_supplier_products, source: :from_product, order: 'id ASC'
  has_one  :supplier_product,  through: :sources_supplier_product,  source: :from_product, order: 'id ASC', autosave: true
  has_many :suppliers, through: :sources_supplier_products, uniq: true, order: 'id ASC'
  has_one  :supplier,  through: :sources_supplier_product, order: 'id ASC'

  has_many :consumers, through: :to_products, source: :profile, uniq: true, order: 'id ASC'
  has_one  :consumer,  through: :to_product,  source: :profile, order: 'id ASC'

  # overhide original
  scope :available, -> {
    joins(:suppliers).
    where 'products.available = ? AND suppliers_plugin_suppliers.active = ?', true, true
  }
  scope :unavailable, -> {
    where 'products.available <> ? OR suppliers_plugin_suppliers.active <> ?', true, true
  }
  scope :with_available, -> (available) {
    op = if available then '=' else '<>' end
    cond = if available then 'AND' else 'OR' end
    where "products.available #{op} ? #{cond} suppliers_plugin_suppliers.active #{op} ?", true, true
  }

  scope :name_like, lambda { |name| where "from_products_products.name ILIKE ?", "%#{name}%" }
  scope :with_product_category_id, lambda { |id| where 'from_products_products.product_category_id = ?', id }

  # prefer distributed_products has_many to use DistributedProduct scopes and eager loading
  scope :distributed, -> { where type: 'SuppliersPlugin::DistributedProduct'}
  scope :own, -> { where type: nil }
  scope :supplied, -> {
    where(type: [nil, 'SuppliersPlugin::DistributedProduct']).
    # this allow duplicates and sorting on the fields
    group('products.id')
  }
  scope :supplied_for_count, -> {
    where(type: [nil, 'SuppliersPlugin::DistributedProduct']).uniq
  }

  scope :from_supplier, lambda { |supplier| { conditions: ['suppliers_plugin_suppliers.id = ?', supplier.id] } }
  scope :from_supplier_id, lambda { |supplier_id| { conditions: ['suppliers_plugin_suppliers.id = ?', supplier_id] } }

  after_create :distribute_to_consumers

  def own?
    self.class == Product
  end
  def distributed?
    self.class == SuppliersPlugin::DistributedProduct
  end
  def supplied?
    self.own? or self.distributed?
  end

  def supplier
    # FIXME: use self.suppliers when rails support for nested preload comes
    @supplier ||= self.sources_supplier_product.supplier rescue nil
    @supplier ||= self.profile.self_supplier rescue nil
  end
  def supplier= value
    @supplier = value
  end
  def supplier_id
    self.supplier.id
  end
  def supplier_id= id
    @supplier = profile.environment.profiles.find id
  end

  def supplier_dummy?
    self.supplier ? self.supplier.dummy? : self.profile.dummy?
  end

  def distribute_to_consumer consumer, attrs = {}
    distributed_product = consumer.distributed_products.where(profile_id: consumer.id, from_products_products: {id: self.id}).first
    distributed_product ||= SuppliersPlugin::DistributedProduct.create! profile: consumer, from_products: [self]
    distributed_product.update_attributes! attrs if attrs.present?
    distributed_product
  end

  def destroy_dependent
    self.to_products.each do |to_product|
      to_product.destroy if to_product.respond_to? :dependent? and to_product.dependent?
    end
  end

  # before_destroy and after_destroy don't work,
  # see http://stackoverflow.com/questions/14175330/associations-not-loaded-in-before-destroy-callback
  def destroy
    self.class.transaction do
      self.destroy_dependent
      super
    end
  end

  def diff from = self.from_product
    return @changed_attrs if @changed_attrs
    @changed_attrs = []
    SuppliersPlugin::BaseProduct::CORE_DEFAULT_ATTRIBUTES.each do |attr|
      @changed_attrs << attr if self[attr].present? and self[attr] != from[attr]
    end
    @changed_attrs
  end

  protected

  def distribute_to_consumers
    # shopping_cart creates products without a profile...
    return unless self.profile

    self.profile.consumers.except_people.except_self.each do |consumer|
      self.distribute_to_consumer consumer.profile
    end
  end

end
