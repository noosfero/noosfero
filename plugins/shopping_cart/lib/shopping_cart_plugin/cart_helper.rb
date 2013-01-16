module ShoppingCartPlugin::CartHelper

  include ActionView::Helpers::NumberHelper
  include ActionView::Helpers::TagHelper

  def sell_price(product)
    return 0 if product.price.nil?
    product.discount ? product.price_with_discount : product.price
  end

  def get_price(product, environment, quantity=1)
    float_to_currency_cart(price_with_quantity(product,quantity), environment)
  end

  def price_with_quantity(product, quantity=1)
    quantity = 1 if !quantity.kind_of?(Numeric)
    sell_price(product)*quantity
  end

  def get_total(items)
    items.map { |id, quantity| price_with_quantity(Product.find(id),quantity)}.sum
  end

  def get_total_on_currency(items, environment)
    float_to_currency_cart(get_total(items), environment)
  end

  def items_table(items, profile, delivery_option = nil, by_mail = false)
    environment = profile.environment
    settings = Noosfero::Plugin::Settings.new(profile, ShoppingCartPlugin)
    items = items.to_a

    quantity_opts = { :class => 'cart-table-quantity' }
    quantity_opts.merge!({:align => 'center'}) if by_mail
    price_opts = {:class => 'cart-table-price'}
    price_opts.merge!({:align => 'right'}) if by_mail
    items.sort! {|a, b| Product.find(a.first).name <=> Product.find(b.first).name}

    if settings.delivery
      if settings.free_delivery_price && get_total(items) >= settings.free_delivery_price
        delivery = Product.new(:name => _('Free delivery'), :price => 0)
      else
        delivery = Product.new(:name => delivery_option || _('Delivery'), :price => settings.delivery_options[delivery_option])
      end
      delivery.save(false)
      items << [delivery.id, '']
    end

    table = '<table id="cart-items-table" cellpadding="2" cellspacing="0"
    border="'+(by_mail ? '1' : '0')+'"
    style="'+(by_mail ? 'border-collapse:collapse' : '')+'">' +
    content_tag('tr',
      content_tag('th', _('Item name')) +
      content_tag('th', by_mail ? '&nbsp;#&nbsp;' : '#') +
      content_tag('th', _('Price'))
    ) +
    items.map do |id, quantity|
      product = Product.find(id)
      name_opts = {}
      is_delivery = quantity.kind_of?(String)
      if is_delivery
        price_opts.merge!({:id => 'delivery-price'})
        name_opts.merge!({:id => 'delivery-name'})
      end
      content_tag('tr',
        content_tag('td', product.name, name_opts) +
        content_tag('td', quantity, quantity_opts ) +
        content_tag('td', get_price(product, environment, quantity), price_opts)
      )
    end.join("\n")

    total = get_total_on_currency(items, environment)
    delivery.destroy if settings.delivery

    table +
    content_tag('th', _('Total:'), :colspan => 2, :class => 'cart-table-total-label') +
    content_tag('th', total, :class => 'cart-table-total-value') +
    '</table>'
  end

  def float_to_currency_cart(value, environment)
    number_to_currency(value, :unit => environment.currency_unit, :separator => environment.currency_separator, :delimiter => environment.currency_delimiter, :precision => 2, :format => "%u%n")
  end

  def select_delivery_options(options, environment)
    result = options.map do |option, price|
      ["#{option} (#{float_to_currency_cart(price, environment)})", option]
    end
    result << ["#{_('Delivery')} (#{float_to_currency_cart(0, environment)})", 'delivery'] if result.empty?
    result
  end
end
