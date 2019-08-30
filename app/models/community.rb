class Community < Organization
  attr_accessible :accessor_id, :accessor_type, :role_id, :resource_id,
                  :resource_type, :address_reference, :district, :language, :description

  after_destroy :check_invite_member_for_destroy

  def self.type_name
    _("Community")
  end

  N_("community")
  N_("Language")

  settings_items :language

  extend SetProfileRegionFromCityState::ClassMethods
  set_profile_region_from_city_state

  before_create do |community|
    community.moderated_articles = true if community.environment.enabled?("organizations_are_moderated_by_default")
  end

  def check_invite_member_for_destroy
    InviteMember.pending.select { |task| task.community_id == self.id }.map(&:destroy)
  end

  # Since it's not a good idea to add the environment as accessible through
  # mass-assignment, we set it manually here. Note that this requires that the
  # places that call this method are safe from mass-assignment by setting the
  # environment key themselves.
  def self.create_after_moderation(requestor, attributes = {})
    environment = attributes[:environment]
    community = Community.new(attributes)
    community.environment = environment
    if community.environment.enabled?("admin_must_approve_new_communities")
      CreateCommunity.create!(attributes.merge(requestor: requestor, environment: environment))
    else
      community.save!
      community.add_admin(requestor)
    end
    community
  end

  xss_terminate only: [:name, :address, :contact_phone, :description], on: :validation

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
    articles.news(self, limit, highlight)
            .reorder("articles.position DESC, published_at DESC")
  end

  def each_member(offset = 0)
    while member = self.members.order(:id).offset(offset).first
      yield member
      offset = offset + 1
    end
  end

  def exclude_verbs_on_activities
    %w[join_community leave_scrap]
  end

  def default_set_of_blocks
    return angular_theme_default_set_of_blocks if Theme.angular_theme?(environment.theme)

    links = set_links
    [
      [MainBlock.new],
      [ProfileImageBlock.new(show_name: true), LinkListBlock.new(links: links), RecentDocumentsBlock.new]
    ]
  end

  def angular_theme_default_set_of_blocks
    @boxes_limit = 2
    self.layout_template = "rightbar"
    [
      [MenuBlock.new, MainBlock.new],
      [CommunitiesBlock.new, TagsCloudBlock.new]
    ]
  end
end
