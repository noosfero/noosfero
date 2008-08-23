class Community < Organization
  N_('Community')

  settings_items :description

  xss_terminate :only => [ :name, :address, :contact_phone, :description ]

  def name=(value)
    super(value)
    self.identifier = value.to_slug
  end

  def template
    environment.community_template
  end

end
