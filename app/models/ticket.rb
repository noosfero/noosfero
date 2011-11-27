class Ticket < Task
  settings_items :name, :message

  def title
    _('Ticket') + (name ? ': '+name : '')
  end
end
