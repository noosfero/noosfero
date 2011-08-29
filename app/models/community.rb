class Community < Organization
  N_('Community')
  N_('Language')

  settings_items :language
  settings_items :zip_code, :city, :state, :country

  before_create do |community|
    community.moderated_articles = true if community.environment.enabled?('organizations_are_moderated_by_default')
  end

  def self.create_after_moderation(requestor, attributes = {})
    community = Community.new(attributes)
    if community.environment.enabled?('admin_must_approve_new_communities')
      CreateCommunity.create(attributes.merge(:requestor => requestor))
    else
      community = Community.create(attributes)
      community.add_admin(requestor)
    end
    community
  end

  xss_terminate :only => [ :name, :address, :contact_phone, :description ], :on => 'validation'

  FIELDS = %w[
    language
  ]

  def self.fields
    super + FIELDS
  end

  def validate
    super
    self.required_fields.each do |field|
      if self.send(field).blank?
        self.errors.add(field, _('%{fn} can\'t be blank'))
      end
    end
  end

  def active_fields
    environment ? environment.active_community_fields : []
  end

  def required_fields
    environment ? environment.required_community_fields : []
  end

  def signup_fields
    environment ? environment.signup_community_fields : []
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

  def blocks_to_expire_cache
    [MembersBlock]
  end

  def each_member(offset=0)
    while member = self.members.first(:order => :id, :offset => offset)
      yield member
      offset = offset + 1
    end
  end

  def control_panel_settings_button
    {:title => __('Community Info and settings'), :icon => 'edit-profile-group'}
  end

end
