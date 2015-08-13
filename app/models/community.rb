class Community < Organization

  attr_accessible :accessor_id, :accessor_type, :role_id, :resource_id, :resource_type, :address_reference, :district, :tag_list, :language
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
    environment.community_default_template
  end

  def news(limit = 30, highlight = false)
    recent_documents(limit, ["articles.type != ? AND articles.highlighted = ?", 'Folder', highlight])
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

  def exclude_verbs_on_activities
    %w[join_community leave_scrap]
  end

end
