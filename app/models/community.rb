class Community < Organization

  def self.type_name
    _('Community')
  end

  N_('Community')
  N_('Language')

  settings_items :language
  settings_items :zip_code, :city, :state, :country

  extend SetProfileRegionFromCityState::ClassMethods
  set_profile_region_from_city_state

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
        self.errors.add_on_blank(field)
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
    self.identifier ||= value.to_slug
  end

  def default_template
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

  def activities
    Scrap.find_by_sql("SELECT id, updated_at, '#{Scrap.to_s}' AS klass FROM #{Scrap.table_name} WHERE scraps.receiver_id = #{self.id} AND scraps.scrap_id IS NULL UNION SELECT id, updated_at, '#{ActionTracker::Record.to_s}' AS klass FROM #{ActionTracker::Record.table_name} WHERE action_tracker.target_id = #{self.id} and action_tracker.verb != 'join_community' and action_tracker.verb != 'leave_scrap' UNION SELECT at.id, at.updated_at, '#{ActionTracker::Record.to_s}' AS klass FROM #{ActionTracker::Record.table_name} at INNER JOIN articles a ON at.target_id = a.id WHERE a.profile_id = #{self.id} AND at.target_type = 'Article' ORDER BY updated_at DESC")
  end

end
