if defined? OrdersPlugin
  require_dependency "#{File.dirname __FILE__}/../ext/orders_plugin/item"
end

class SuppliersPlugin::Base < Noosfero::Plugin
  def stylesheet?
    true
  end

  def js_files
    ["locale", "toggle_edit", "sortable-table", "suppliers"].map { |j| "javascripts/#{j}" }
  end

  ProductTabs = {
    distribution: {
      id: "product-distribution",
      content: ->(_) {
        render "suppliers_plugin/manage_products/distribution_tab"
      }
    },
    compare: {
      id: "product-compare-origin",
      content: ->(_) {
        render "suppliers_plugin/manage_products/compare_tab"
      }
    },
    basket: {
      id: "product-basket",
      content: ->(_) {
        render "suppliers_plugin/manage_products/basket_tab"
      }
    },
  }

  def product_tabs(product)
    allowed_user = context.instance_variable_get :@allowed_user

    tabs = ProductTabs.dup
    tabs.delete :distribution unless allowed_user && product.profile.orgs_consumers.present?
    tabs.delete :compare unless allowed_user && (product.from_products.size == 1)
    # for now, only support basket as a product of the profile
    tabs.delete :basket unless product.own? && (allowed_user || (product.from_products.size > 1))
    tabs.each { |t, op| op[:title] = I18n.t "suppliers_plugin.lib.plugin.#{t}_tab" }
    tabs.values
  end

  def control_panel_entries
    [SupplierPlugin::ControlPanel::Suppliers, SupplierPlugin::ControlPanel::SuppliersProducts]
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
