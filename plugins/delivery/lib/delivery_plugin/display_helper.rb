module DeliveryPlugin::DisplayHelper

  def input_group_addon unit
    yield
  end unless defined? ResponsivePlugin

  def supplier_delivery_options options = {}
    selected = options[:selected]
    methods = options[:methods] || profile.delivery_methods

    options = methods.map do |method|
      cost = if method.fixed_cost.present? and method.fixed_cost > 0 then float_to_currency_cart(method.fixed_cost, environment) else nil end
      text = if cost.present? then "#{method.name} (#{cost})" else method.name end

      content_tag :option, text, value: method.id,
        data: {label: method.name, type: method.delivery_type, instructions: method.description.to_s},
        selected: if method == selected then 'selected' else nil end
    end.join
  end

  def delivery_context
    @delivery_context || 'delivery_plugin/admin_method'
  end

end
