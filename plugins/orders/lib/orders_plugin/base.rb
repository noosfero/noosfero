class OrdersPlugin::Base < Noosfero::Plugin
  def stylesheet?
    true
  end

  def js_files
    ['locale', 'toggle_edit', 'sortable-table', 'help', 'orders'].map{ |j| "javascripts/#{j}" }
  end

  def control_panel_entries
    [OrdersPlugin::ControlPanel::Orders, OrdersPlugin::ControlPanel::Sales]
  end

  def control_panel_sections
    [{shopping: {name: _('Shopping'), priority: 71}}]
  end
end
