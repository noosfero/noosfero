class ShoppingCartPlugin::Mailer < Noosfero::Plugin::MailerBase

  include ShoppingCartPlugin::CartHelper

  helper ShoppingCartPlugin::CartHelper

  attr_accessor :environment, :profile

  def customer_notification order, items
    domain = order.profile.hostname || order.profile.environment.default_hostname
    self.profile = order.profile
    self.environment = order.profile.environment
    @order = order
    @items = items

    mail(
      to:           @order.consumer_data[:email],
      from:         'no-reply@' + domain,
      reply_to:     @order.profile.cart_order_supplier_notification_recipients,
      subject:      _("[%s] Your buy request was performed successfully.") % @order.profile.short_name(nil),
      content_type: 'text/html'
    )
  end

  def supplier_notification order, items
    domain = order.profile.environment.default_hostname
    self.profile = order.profile
    self.environment = order.profile.environment
    @order = order
    @items = items

    mail(
      to:            @order.profile.cart_order_supplier_notification_recipients,
      from:          'no-reply@' + domain,
      reply_to:      @order.consumer_data[:email],
      subject:       _("[%s] You have a new buy request from %s.") % [order.profile.environment.name, @order.consumer_data[:name]],
      content_type:  'text/html'
    )
  end
end
