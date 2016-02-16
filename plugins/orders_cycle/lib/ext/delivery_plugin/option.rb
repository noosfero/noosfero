require_dependency 'delivery_plugin/option'

class DeliveryPlugin::Option

  belongs_to :cycle, -> {
    where "delivery_plugin_options.owner_type = 'OrdersCyclePlugin::Cycle'"
  }, class_name: 'OrdersCyclePlugin::Cycle', foreign_key: :owner_id

end
