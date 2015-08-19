module OrdersPlugin::AdminHelper

  protected

  def order_situation order
    situation = order.situation
    order.situation.each_with_index.map do |status, i|
      classes = status.dup #do not change the status itself!
      text = t("orders_plugin.models.order.statuses.#{status}")
      if i == situation.size - 1
        classes << ' last'
      else
        text = text.chars.first
      end
      text += ' '

      content_tag 'span', text, :class => classes
    end.join ' '
  end

end
