class ShoppingCartPlugin < Noosfero::Plugin

  def self.plugin_name
    "Shopping Cart"
  end

  def self.plugin_description
    _("A shopping cart feature for enterprises")
  end

  def add_to_cart_button(item, enterprise = context.profile)
    if enterprise.shopping_cart
       lambda {
         link_to(_('Add to cart'), "add:#{item.name}",
           :class => 'cart-add-item',
           :onclick => "Cart.addItem('#{enterprise.identifier}', #{item.id}, this); return false"
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
    ['cart.js', 'colorbox/jquery.colorbox.js']
  end

  def body_beginning
    expanded_template('cart.html.erb',{:cart => context.session[:cart]})
  end

  def control_panel_buttons
    if context.profile.enterprise?
      { :title => 'Shopping cart', :icon => 'shopping_cart_icon', :url => {:controller => 'shopping_cart_plugin_myprofile', :action => 'edit'} }
    end
  end

end
