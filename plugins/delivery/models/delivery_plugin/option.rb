class DeliveryPlugin::Option < ActiveRecord::Base

  belongs_to :delivery_method, :class_name => 'DeliveryPlugin::Method'
  belongs_to :owner, :polymorphic => true

  validates_presence_of :delivery_method
  validates_presence_of :owner

  attr_accessible :owner_id, :owner_type, :delivery_methods, :delivery_method

end
