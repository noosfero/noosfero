class DeliveryPlugin::Method < ActiveRecord::Base

  extend CurrencyHelper::ClassMethods

  Types = ['pickup', 'deliver']

  # see also: Profile::LOCATION_FIELDS
  AddressFields = %w[
    address address_line2 address_reference district city state country_name zip_code
  ].map(&:to_sym)

  attr_accessible :profile, :delivery_type, :name, :description,
    :fixed_cost, :free_over_price

  belongs_to :profile

  has_many :delivery_options, class_name: 'DeliveryPlugin::Option', foreign_key: :delivery_method_id, dependent: :destroy

  validates_presence_of :profile
  validates_presence_of :name
  validates_inclusion_of :delivery_type, in: Types

  scope :pickup, conditions: {delivery_type: 'pickup'}
  scope :delivery, conditions: {delivery_type: 'deliver'}

  def pickup?
    self.delivery_type == 'pickup'
  end
  def deliver?
    self.delivery_type == 'deliver'
  end

  def has_cost? order_price=nil
    if order_price.present? and order_price.nonzero? and self.free_over_price.present? and self.free_over_price.nonzero?
      order_price <= self.free_over_price
    else
      self.fixed_cost.present? and self.fixed_cost.nonzero?
    end
  end
  def free? order_price=nil
    !self.has_cost?
  end

  def cost order_price=nil
    if self.has_cost?(order_price) then self.fixed_cost.to_f else 0 end
  end
  has_currency :fixed_cost
  has_currency :free_over_price
  has_currency :cost

  protected

end
