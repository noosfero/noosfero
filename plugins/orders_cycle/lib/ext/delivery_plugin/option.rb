require_dependency 'delivery_plugin/option'

class DeliveryPlugin::Option

  belongs_to :cycle, class_name: 'OrdersCyclePlugin::Cycle',
    foreign_key: :owner_id, conditions: ["delivery_plugin_options.owner_type = 'OrdersCyclePlugin::Cycle'"]

end
