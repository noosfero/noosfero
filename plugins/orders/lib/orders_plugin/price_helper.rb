module OrdersPlugin::PriceHelper

  protected

  def price_with_unit_span price, unit, detail=nil, options = {}
    return nil if price.blank?

    # the scoped class is styled globally
    options[:class] = "orders-price-with-unit price-with-unit #{options[:class]}"

    detail ||= ''
    detail = " (#{detail})" if detail.present?
    unit = "#{t('lib.price_helper./')} #{unit.singular}" rescue ''
    text = t('lib.price_helper.price_unit') % {
      :price => price_span(price),
      :unit => content_tag('div', unit + detail, :class => 'price-unit', :title => (unit + detail)),
    }

    content_tag 'div', text, options
  end

end
