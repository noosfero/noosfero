class Community < Organization
  N_('Community')

  settings_items :description

  xss_terminate :only => [ :description ]

  def name=(value)
    super(value)
    self.identifier = value.to_slug
  end

end
