class OrdersPlugin::Base < Noosfero::Plugin

  def stylesheet?
    true
  end

  def js_files
    ['locale', 'toggle_edit', 'sortable-table', 'help', 'orders'].map{ |j| "javascripts/#{j}" }
  end

  def control_panel_buttons
    [
      {
        :title => I18n.t("orders_plugin.lib.plugin.#{'person_' if profile.person?}panel_button"),
        :icon => 'orders-purchases-sales', :url => {:controller => :orders_plugin_admin, :action => :index},
      },
    ]
  end

end

