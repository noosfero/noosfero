class ShoppingCartPlugin < Noosfero::Plugin

  def self.plugin_name
    "Shopping Basket"
  end

  def self.plugin_description
    _("A shopping basket feature for enterprises")
  end

  def stylesheet?
    true
  end

  def js_files
    'cart.js'
  end

  def body_beginning
    lambda do
    	extend ShoppingCartPlugin::CartHelper
      render 'public/cart' unless cart_minimized
    end
  end

  def control_panel_buttons
    buttons = []
    if context.profile.enterprise?
      buttons << { :title => _('Shopping basket'), :icon => 'shopping-cart-icon', :url => {:controller => 'shopping_cart_plugin_myprofile', :action => 'edit'} }
    end

    buttons
  end

  def add_to_cart_button item, options = {}
    profile = item.profile
    return unless profile.shopping_cart_enabled and item.available
    lambda do
      extend ShoppingCartPlugin::CartHelper
      add_to_cart_button item, options
    end
  end

  alias :product_info_extras :add_to_cart_button
  alias :catalog_item_extras :add_to_cart_button
  alias :asset_product_extras :add_to_cart_button

  # We now think that it's not a good idea to have the basket in the same time.
  #def catalog_autocomplete_item_extras product
  #  add_to_cart_button product, with_text: false
  #end

  def catalog_search_extras_begin
    return unless profile.shopping_cart_enabled
    lambda do
      extend ShoppingCartPlugin::CartHelper
      content_tag 'li', render('public/cart'), :class => 'catalog-cart'
    end
  end

end
