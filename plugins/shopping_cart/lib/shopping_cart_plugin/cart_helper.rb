module ShoppingCartPlugin::CartHelper

  include ActionView::Helpers::NumberHelper

  def sell_price(product)
    return 0 if product.price.nil?
    product.discount ? product.price_with_discount : product.price
  end

  def get_price(product)
    float_to_currency(sell_price(product))
  end

  def get_total(items)
    float_to_currency(items.map { |id, quantity| sell_price(Product.find(id)) * quantity}.sum)
  end

  def items_table(items, by_mail = false)
    '<table id="cart-items-table" cellpadding="2" cellspacing="0"
    border="'+(by_mail ? '1' : '0')+'"
    style="'+(by_mail ? 'border-collapse:collapse' : '')+'">' +
    content_tag('tr',
                content_tag('th', _('Item name')) +
                content_tag('th', by_mail ? '&nbsp;#&nbsp;' : '#') +
                content_tag('th', _('Price'))
    ) +
    items.map do |id, quantity|
      product = Product.find(id)
      quantity_opts = { :class => 'cart-table-quantity' }
      quantity_opts.merge!({:align => 'center'}) if by_mail
      price_opts = {:class => 'cart-table-price'}
      price_opts.merge!({:align => 'right'}) if by_mail
      content_tag('tr',
                  content_tag('td', product.name) +
                  content_tag('td', quantity, quantity_opts ) +
                  content_tag('td', get_price(product), price_opts )
                 )
    end.join("\n") +
    content_tag('th', _('Total:'), :colspan => 2, :class => 'cart-table-total-label') +
    content_tag('th', get_total(items), :class => 'cart-table-total-value') +
    '</table>'
  end

end
