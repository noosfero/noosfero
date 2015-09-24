require_dependency 'profile'

# FIXME: The lines bellow should be on the core
class Profile

  has_many :products

  def create_product?
    true
  end

end

class Profile

  # use profile.products.supplied to include own products
  has_many :distributed_products, class_name: 'SuppliersPlugin::DistributedProduct'

  has_many :from_products, through: :products
  has_many :to_products, through: :products

  has_many :suppliers, class_name: 'SuppliersPlugin::Supplier', foreign_key: :consumer_id, dependent: :destroy,
    include: [{profile: [:domains], consumer: [:domains]}], order: 'name ASC'
  has_many :consumers, class_name: 'SuppliersPlugin::Consumer', foreign_key: :profile_id, dependent: :destroy,
    include: [{profile: [:domains], consumer: [:domains]}], order: 'name ASC'

  def supplier_settings
    @supplier_settings ||= Noosfero::Plugin::Settings.new self, SuppliersPlugin
  end

  def dummy?
    !self.visible
  end

  def orgs_consumers
    @orgs_consumers ||= self.consumers.except_people.except_self
  end

  def self_supplier
    @self_supplier ||= if new_record?
      self.suppliers_without_self_supplier.build profile: self
    else
      suppliers_without_self_supplier.select{ |s| s.profile_id == s.consumer_id }.first || self.suppliers_without_self_supplier.create(profile: self)
    end
  end
  def suppliers_with_self_supplier
    self_supplier # guarantee that the self_supplier is created
    suppliers_without_self_supplier
  end
  alias_method_chain :suppliers, :self_supplier

  def add_consumer consumer_profile
    consumer = self.consumers.where(consumer_id: consumer_profile.id).first
    consumer ||= self.consumers.create! profile: self, consumer: consumer_profile
  end
  def remove_consumer consumer_profile
    consumer = self.consumers.of_consumer(consumer_profile).first
    consumer.destroy if supplier
  end

  def add_supplier supplier_profile, attrs={}
    supplier = self.suppliers.where(profile_id: supplier_profile.id).first
    supplier ||= self.suppliers.create! attrs.merge(profile: supplier_profile, consumer: self)
  end
  def remove_supplier supplier_profile
    supplier_profile.remove_consumer self
  end

  def not_distributed_products supplier
    raise "'#{supplier.name}' is not a supplier of #{self.name}" if self.suppliers.of_profile(supplier).blank?

    # FIXME: only select all products if supplier is dummy
    supplier.profile.products.unarchived.own - self.from_products.unarchived.by_profile(supplier.profile)
  end

  delegate :margin_percentage, :margin_percentage=, to: :supplier_settings
  extend CurrencyHelper::ClassMethods
  has_number_with_locale :margin_percentage

  def supplier_products_default_margins
    self.class.transaction do
      self.distributed_products.unarchived.each do |product|
        product.default_margin_percentage = true
        product.save!
      end
    end
  end

end
