require_dependency 'ext/enterprise'
require_dependency 'ext/person'

class ShoppingCartPlugin < Noosfero::Plugin

  def self.plugin_name
    "Shopping Cart"
  end

  def self.plugin_description
    _("A shopping cart feature for enterprises")
  end

  def add_to_cart_button(item, enterprise = context.profile)
    if enterprise.shopping_cart && item.available
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
    language = FastGettext.locale
    [ 'cart.js',
      'colorbox/jquery.colorbox.js',
      'jquery-validation/jquery.validate.js',
      'jquery-validation/localization/messages_'+language+'.js',
      'jquery-validation/localization/methods_'+language+'.js'
    ]
  end

  def body_beginning
    expanded_template('cart.html.erb',{:cart => context.session[:cart]})
  end

  def control_panel_buttons
    buttons = []
    if context.profile.enterprise?
      buttons << { :title => 'Shopping cart', :icon => 'shopping_cart_icon', :url => {:controller => 'shopping_cart_plugin_myprofile', :action => 'edit'} }
    end
    if context.profile.enterprise? && context.profile.shopping_cart
      buttons << { :title => 'Purchase reports', :icon => 'shopping-cart-purchase-report', :url => {:controller => 'shopping_cart_plugin_myprofile', :action => 'reports'} }
    end

    buttons
  end
end
