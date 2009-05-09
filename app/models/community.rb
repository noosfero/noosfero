class Community < Organization
  N_('Community')
  N_('Language')

  settings_items :description
  settings_items :language

  xss_terminate :only => [ :name, :address, :contact_phone, :description ]

  FIELDS = %w[
    description
    language
  ]

  def self.fields
    super + FIELDS
  end

  def validate
    self.required_fields.each do |field|
      if self.send(field).blank?
          self.errors.add(field, _('%{fn} is mandatory'))
      end
    end
  end

  def active_fields
    environment ? environment.active_community_fields : []
  end

  def required_fields
    environment ? environment.required_community_fields : []
  end

  def name=(value)
    super(value)
    self.identifier = value.to_slug
  end

  def template
    environment.community_template
  end

  def news(limit = 30, highlight = false)
    recent_documents(limit, ["articles.type != ? AND articles.highlighted = ?", 'Folder', highlight])
  end
end
