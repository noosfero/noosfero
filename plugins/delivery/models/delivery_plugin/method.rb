class DeliveryPlugin::Method < ActiveRecord::Base

  Types = ['pickup', 'deliver']

  # see also: Profile::LOCATION_FIELDS
  AddressFields = %w[
    address address_line2 address_reference district city state country_name zip_code
  ].map(&:to_sym)

  attr_accessible :profile, :delivery_type, :name, :description,
    :fixed_cost, :free_over_price, :distribution_margin_percentage, :distribution_margin_fixed

  belongs_to :profile

  has_many :delivery_options, class_name: 'DeliveryPlugin::Option', foreign_key: :delivery_method_id, dependent: :destroy

  validates_presence_of :profile
  validates_presence_of :name
  validates_inclusion_of :delivery_type, in: Types

  scope :pickup, -> { where delivery_type: 'pickup' }
  scope :delivery, -> { where delivery_type: 'deliver'}

  extend CurrencyHelper::ClassMethods
  has_currency :fixed_cost
  has_currency :free_over_price
  has_currency :distribution_margin_percentage
  has_currency :distribution_margin_fixed

  def pickup?
    self.delivery_type == 'pickup'
  end
  def deliver?
    self.delivery_type == 'deliver'
  end

  def has_distribution_margin?
    (self.distribution_margin_percentage.present? and self.distribution_margin_percentage.nonzero?) or
      (self.distribution_margin_fixed.present? and self.distribution_margin_fixed.nonzero?)
  end

  def has_fixed_cost? order_price=nil
    if order_price.present? and order_price.nonzero? and self.free_over_price.present? and self.free_over_price.nonzero?
      order_price <= self.free_over_price
    else
      self.fixed_cost.present? and self.fixed_cost.nonzero?
    end
  end

  def distribution_margin order_price
    value = 0
    value += self.distribution_margin_fixed if self.distribution_margin_fixed.present?
    value += order_price * (self.distribution_margin_percentage/100) if self.distribution_margin_percentage.present?
    value
  end

  def has_cost? order_price=nil
    has_cost = self.has_distribution_margin?
    has_cost ||= self.has_fixed_cost? order_price
  end
  def free? order_price=nil
    !self.has_cost?
  end

  def cost order_price=nil
    value = 0
    value += self.fixed_cost if self.has_fixed_cost? order_price
    value += self.distribution_margin order_price if self.has_distribution_margin?
    value
  end
  has_currency :cost

  protected

end
