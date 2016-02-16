class SuppliersPlugin::Supplier < ActiveRecord::Base

  attr_accessor :distribute_products_on_create, :dont_destroy_dummy, :identifier_from_name

  attr_accessible :profile_id, :profile, :consumer, :consumer_id, :name, :name_abbreviation, :description

  belongs_to :profile
  belongs_to :consumer, class_name: 'Profile'
  alias_method :supplier, :profile

  validates_presence_of :name, if: :dummy?
  validates_associated :profile, if: :dummy?
  validates_presence_of :profile
  validates_presence_of :consumer
  validates_uniqueness_of :consumer_id, scope: :profile_id, if: :profile_id

  scope :alphabetical, -> { order 'name ASC' }

  scope :active, -> { where active: true }
  scope :dummy, -> { joins(:profile).where profiles: {visible: false} }

  scope :of_profile, -> (p) { where profile_id: p.id }
  scope :of_profile_id, -> (id) { where profile_id: id }
  scope :of_consumer, -> (c) { where consumer_id: c.id }
  scope :of_consumer_id, -> (id) { where consumer_id: id }

  scope :from_supplier_id, -> (supplier_id) { where 'suppliers_plugin_suppliers.id = ?', supplier_id }

  scope :with_name, -> (name) { where "suppliers_plugin_suppliers.name ILIKE ?", "%#{name.downcase}%" if name }
  scope :by_active, -> (active) { where active: active if active }

  scope :except_people, -> { joins(:consumer).where 'profiles.type <> ?', Person.name }
  scope :except_self, -> { where 'profile_id <> consumer_id' }

  after_create :add_admins, if: :dummy?
  after_create :save_profile, if: :dummy?
  after_create :distribute_products_to_consumer
  before_validation :fill_identifier, if: :dummy?
  before_destroy :destroy_consumer_products

  def self.new_dummy attributes
    environment = attributes[:consumer].environment
    profile = environment.enterprises.build
    profile.enabled = false
    profile.visible = false
    profile.public_profile = false

    supplier = self.new
    supplier.profile = profile
    supplier.consumer = attributes.delete :consumer
    supplier.attributes = attributes
    supplier
  end
  def self.create_dummy attributes
    s = new_dummy attributes
    s.save!
    s
  end

  def self?
    self.profile_id == self.consumer_id
  end
  def person?
    self.consumer.person?
  end
  def dummy?
    !self.supplier.visible rescue false
  end
  def active?
    self.active
  end

  def name
    self.attributes['name'] || self.profile.name
  end
  def name= value
    self['name'] = value
    self.supplier.name = value if self.dummy? and not self.supplier.frozen?
  end
  def description
    self.attributes['description'] || self.profile.description
  end
  def description= value
    self['description'] = value
    self.supplier.description = value if self.dummy? and not self.supplier.frozen?
  end

  def abbreviation_or_name
    return self.profile.nickname || self.name if self.self?
    self.name_abbreviation.blank? ? self.name : self.name_abbreviation
  end

  def destroy_with_dummy
    if not self.self? and not self.dont_destroy_dummy and self.supplier and self.supplier.dummy?
      self.supplier.destroy
    end
    self.destroy_without_dummy
  end
  alias_method_chain :destroy, :dummy

  protected

  def set_identifier
    if self.identifier_from_name
      identifier = self.profile.identifier = self.profile.name.to_slug
      i = 0
      self.profile.identifier = "#{identifier}#{i += 1}" while Profile[self.profile.identifier].present?
    else
      self.profile.identifier = Digest::MD5.hexdigest rand.to_s
    end
  end

  def fill_identifier
    return if self.profile.identifier.present?
    set_identifier
  end

  def add_admins
    self.consumer.admins.to_a.each{ |a| self.supplier.add_admin a }
  end

  # sync name, description, etc
  def save_profile
    self.supplier.save
  end

  def distribute_products_to_consumer
    self.distribute_products_on_create = true if self.distribute_products_on_create.nil?
    return if self.self? or self.consumer.person? or not self.distribute_products_on_create

    already_supplied = self.consumer.distributed_products.unarchived.from_supplier_id(self.id).all

    self.profile.products.unarchived.each do |source_product|
      next if already_supplied.find{ |f| f.supplier_product == source_product }

      source_product.distribute_to_consumer self.consumer
    end
  end
  handle_asynchronously :distribute_products_to_consumer

  def destroy_consumer_products
    self.consumer.products.joins(:suppliers).from_supplier(self).destroy_all
  end

  # delegate missing methods to profile
  def method_missing method, *args, &block
    if self.profile.respond_to? method
      self.profile.send method, *args, &block
    else
      super method, *args, &block
    end
  end
  def respond_to_with_profile? method, include_private=false
    respond_to_without_profile? method, include_private or Profile.new.respond_to? method, include_private
  end
  alias_method_chain :respond_to?, :profile

end
