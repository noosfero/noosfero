class Community < Organization

  attr_accessible :accessor_id, :accessor_type, :role_id, :resource_id, :resource_type
  after_destroy :check_invite_member_for_destroy

  def self.type_name
    _('Community')
  end

  N_('Community')
  N_('Language')

  settings_items :language

  extend SetProfileRegionFromCityState::ClassMethods
  set_profile_region_from_city_state

  before_create do |community|
    community.moderated_articles = true if community.environment.enabled?('organizations_are_moderated_by_default')
  end

  def check_invite_member_for_destroy
      InviteMember.pending.select { |task| task.community_id == self.id }.map(&:destroy)
  end

  # Since it's not a good idea to add the environment as accessible through
  # mass-assignment, we set it manually here. Note that this requires that the
  # places that call this method are safe from mass-assignment by setting the
  # environment key themselves.
  def self.create_after_moderation(requestor, attributes = {})
    environment = attributes.delete(:environment)
    community = Community.new(attributes)
    community.environment = environment
    if community.environment.enabled?('admin_must_approve_new_communities')
      CreateCommunity.create!(attributes.merge(:requestor => requestor, :environment => environment))
    else
      community.save!
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

  validate :presence_of_required_fieds

  def presence_of_required_fieds
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
    {:title => _('Community Info and settings'), :icon => 'edit-profile-group'}
  end

  def activities
    Scrap.find_by_sql("SELECT id, updated_at, '#{Scrap.to_s}' AS klass FROM #{Scrap.table_name} WHERE scraps.receiver_id = #{self.id} AND scraps.scrap_id IS NULL UNION SELECT id, updated_at, '#{ActionTracker::Record.to_s}' AS klass FROM #{ActionTracker::Record.table_name} WHERE action_tracker.target_id = #{self.id} and action_tracker.verb != 'join_community' and action_tracker.verb != 'leave_scrap' UNION SELECT at.id, at.updated_at, '#{ActionTracker::Record.to_s}' AS klass FROM #{ActionTracker::Record.table_name} at INNER JOIN articles a ON at.target_id = a.id WHERE a.profile_id = #{self.id} AND at.target_type = 'Article' ORDER BY updated_at DESC")
  end

end
