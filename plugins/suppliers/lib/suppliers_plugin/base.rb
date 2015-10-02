if defined? OrdersPlugin
  require_dependency "#{File.dirname __FILE__}/../ext/orders_plugin/item"
end

class SuppliersPlugin::Base < Noosfero::Plugin

  def stylesheet?
    true
  end

  def js_files
    ['locale', 'toggle_edit', 'sortable-table', 'suppliers'].map{ |j| "javascripts/#{j}" }
  end

  ProductTabs = {
    distribution: {
      id: 'product-distribution',
      content: lambda do
        render 'suppliers_plugin/manage_products/distribution_tab'
      end
    },
    compare: {
      id: 'product-compare-origin',
      content: lambda do
        render 'suppliers_plugin/manage_products/compare_tab'
      end
    },
    basket: {
      id: 'product-basket',
      content: lambda do
        render 'suppliers_plugin/manage_products/basket_tab'
      end
    },
  }

  def product_tabs product
    allowed_user = context.instance_variable_get :@allowed_user

    tabs = ProductTabs.dup
    tabs.delete :distribution unless allowed_user and product.profile.orgs_consumers.present?
    tabs.delete :compare unless allowed_user and product.from_products.size == 1
    # for now, only support basket as a product of the profile
    tabs.delete :basket unless product.own? and (allowed_user or product.from_products.size > 1)
    tabs.each{ |t, op| op[:title] = I18n.t "suppliers_plugin.lib.plugin.#{t}_tab" }
    tabs.values
  end

  def control_panel_buttons
    # FIXME: disable for now
    return

    profile = context.profile
    return unless profile.enterprise?
    [
      {title: I18n.t('suppliers_plugin.views.control_panel.suppliers'), icon: 'suppliers-manage-suppliers', url: {controller: :suppliers_plugin_myprofile, action: :index}},
      {title: I18n.t('suppliers_plugin.views.control_panel.products'), icon: 'suppliers-manage-suppliers', url: {controller: 'suppliers_plugin/product', action: :index}},
    ]
  end

end

ActiveSupport.on_load :solr_product do
  ::Product.class_eval do
    def solr_supplied
      self.supplied?
    end
    self.solr_extra_fields << :solr_supplied
  end
end

