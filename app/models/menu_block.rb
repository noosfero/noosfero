class MenuBlock < Block

  include SanitizeHelper
  def self.description
    _('Menu Block')
  end

  def help
    _('This block can be used to display a menu for profiles.')
  end

  def self.pretty_name
    _('Menu Block')
  end

end
