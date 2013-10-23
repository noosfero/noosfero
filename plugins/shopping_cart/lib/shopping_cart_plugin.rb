class ShoppingCartPlugin < Noosfero::Plugin

  class << self
    def plugin_name
    "Shopping Basket"
    end

    def plugin_description
      _("A shopping basket feature for enterprises")
    end

    def delivery_default_setting
      false
    end

    def delivery_price_default_setting
      0
    end

    def delivery_options_default_setting
      {}
    end
  end

  def add_to_cart_button(item)
    enterprise = item.enterprise
    settings = Noosfero::Plugin::Settings.new(enterprise, ShoppingCartPlugin)
    if settings.enabled && item.available
       lambda {
         link_to(_('Add to basket'), "add:#{item.name}",
           :class => 'cart-add-item',
           :onclick => "Cart.addItem(#{item.id}, this); return false"
         )
       }
    end
  end

  alias :product_info_extras :add_to_cart_button
  alias :catalog_item_extras :add_to_cart_button
  alias :asset_product_extras :add_to_cart_button

  def stylesheet?
    true
  end

  def js_files
    'cart.js'
  end

  def body_beginning
    expanded_template('cart.html.erb')
  end

  def control_panel_buttons
    settings = Noosfero::Plugin::Settings.new(context.profile, ShoppingCartPlugin)
    buttons = []
    if context.profile.enterprise?
      buttons << { :title => _('Shopping basket'), :icon => 'shopping-cart-icon', :url => {:controller => 'shopping_cart_plugin_myprofile', :action => 'edit'} }
    end
    if context.profile.enterprise? && settings.enabled
      buttons << { :title => _('Purchase reports'), :icon => 'shopping-cart-purchase-report', :url => {:controller => 'shopping_cart_plugin_myprofile', :action => 'reports'} }
    end

    buttons
  end
end
