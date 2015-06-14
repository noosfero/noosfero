require_dependency 'profile'

class Profile

  def shopping_cart_settings attrs = {}
    @shopping_cart_settings ||= Noosfero::Plugin::Settings.new self, ShoppingCartPlugin, attrs
    attrs.each{ |a, v| @shopping_cart_settings.send "#{a}=", v }
    @shopping_cart_settings
  end

  def shopping_cart_enabled
    self.shopping_cart_settings.enabled
  end

  # may be customized by other profiles
  def cart_order_supplier_notification_recipients
    if self.contact_email.present?
      [self.contact_email]
    else
      self.admins.collect(&:contact_email).select{ |email| email.present? }
    end
  end

end
