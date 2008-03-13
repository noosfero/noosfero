class Community < Organization
  N_('Community')

  settings_items :description

  def name=(value)
    super(value)
    self.identifier = value.to_slug
  end

end
