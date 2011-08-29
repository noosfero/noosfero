class ShoppingCartPlugin::PurchaseOrder < Noosfero::Plugin::ActiveRecord

  belongs_to :customer, :class_name => "Profile"
  belongs_to :seller, :class_name => "Profile"

  validates_presence_of :status, :seller

  acts_as_having_settings :field => :data

  settings_items :products_list, :type => Array, :default => {}
  settings_items :customer_name, :type => String
  settings_items :customer_email, :type => String
  settings_items :customer_contact_phone, :type => String
  settings_items :customer_address, :type => String
  settings_items :customer_city, :type => String
  settings_items :customer_zip_code, :type => String

  before_create do |order|
    order.created_at = Time.now.utc
    order.updated_at = Time.now.utc
  end

  before_update do |order|
    order.updated_at = Time.now.utc
  end

  module Status
    OPENED = 0
    CANCELED = 1
    CONFIRMED = 2
    SHIPPED = 3

    def self.name
      [_('Opened'), _('Canceled'), _('Confirmed'), _('Shipped')]
    end
  end
end
