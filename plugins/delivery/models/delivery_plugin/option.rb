class DeliveryPlugin::Option < ApplicationRecord

  belongs_to :delivery_method, class_name: 'DeliveryPlugin::Method', optional: true
  belongs_to :owner, polymorphic: true, optional: true

  validates_presence_of :delivery_method
  validates_presence_of :owner

  attr_accessible :owner_id, :owner_type, :delivery_methods, :delivery_method

end
