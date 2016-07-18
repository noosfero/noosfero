# A pseudo profile is a person from a remote network
class ExternalPerson < ActiveRecord::Base

  include Human
  include ProfileEntity

  validates_uniqueness_of :identifier, scope: :source

  validates_presence_of :source, :email, :created_at

  attr_accessible :source, :email, :created_at

  def self.get_or_create(webfinger)
    user = ExternalPerson.find_by(identifier: webfinger.identifier, source: webfinger.domain)
    if user.nil?
      user = ExternalPerson.create!(identifier: webfinger.identifier,
                                    name: webfinger.name,
                                    source: webfinger.domain,
                                    email: webfinger.email,
                                    created_at: webfinger.created_at
                                   )
    end
    user
  end

  def privacy_setting
    _('Public profile')
  end

  def avatar
    "http://#{self.source}/profile/#{self.identifier}/icon/"
  end

  def url
    "http://#{self.source}/profile/#{self.identifier}"
  end

  alias :public_profile_url :url

  def admin_url
    "http://#{self.source}/myprofile/#{self.identifier}"
  end

  def wall_url
    self.url
  end
  def tasks_url
    self.url
  end
  def leave_url(reload = false)
    self.url
  end
  def join_url
    self.url
  end
  def join_not_logged_url
    self.url
  end
  def check_membership_url
    self.url
  end
  def add_url
    self.url
  end
  def check_friendship_url
    self.url
  end
  def people_suggestions_url
    self.url
  end
  def communities_suggestions_url
    self.url
  end
  def top_url(scheme = 'http')
    "#{scheme}://#{self.source}"
  end

  def profile_custom_icon(gravatar_default=nil)
    self.avatar
  end

  def preferred_login_redirection
    environment.redirection_after_login
  end

  def location
    self.source
  end

  def default_hostname
    environment.default_hostname
  end

  def possible_domains
    environment.domains
  end

  def person?
    true
  end

  def contact_email(*args)
    self.email
  end

  def notification_emails
    [self.contact_email]
  end

  def email_domain
    self.source
  end

  def email_addresses
    ['%s@%s' % [self.identifier, self.source] ]
  end

  def jid(options = {})
    "#{self.identifier}@#{self.source}"
  end
  def full_jid(options = {})
    "#{jid(options)}/#{self.name}"
  end

  def name
    "#{self[:name]}@#{self.source}"
  end

  class ExternalPerson::Image
    def initialize(path)
      @path = path
    end

    def public_filename(size = nil)
      URI.join(@path, size.to_s)
    end

    def content_type
      # This is not really going to be used anywhere that matters
      # so we are hardcodding it here.
      'image/png'
    end
  end

  def image
    ExternalPerson::Image.new(avatar)
  end

  def data_hash(gravatar_default = nil)
    friends_list = {}
    {
      'login' => self.identifier,
      'name' => self.name,
      'email' => self.email,
      'avatar' => self.profile_custom_icon(gravatar_default),
      'is_admin' => self.is_admin?,
      'since_month' => self.created_at.month,
      'since_year' => self.created_at.year,
      'email_domain' => self.source,
      'friends_list' => friends_list,
      'enterprises' => [],
      'amount_of_friends' => friends_list.count,
      'chat_enabled' => false
    }
  end

  # External Person should respond to all methods in Person and Profile
  def person_instance_methods
    methods_and_responses = {
     enterprises: Enterprise.none, communities: Community.none, friends:
     Person.none, memberships: Profile.none, friendships: Person.none,
     following_articles: Article.none, article_followers: ArticleFollower.none,
     requested_tasks: Task.none, mailings: Mailing.none, scraps_sent:
     Scrap.none, favorite_enterprise_people: FavoriteEnterprisePerson.none,
     favorite_enterprises: Enterprise.none, acepted_forums: Forum.none,
     articles_with_access: Article.none, suggested_profiles:
     ProfileSuggestion.none, suggested_people: ProfileSuggestion.none,
     suggested_communities: ProfileSuggestion.none, user: nil,
     refused_communities: Community.none, has_permission?: false,
     has_permission_with_admin?: false, has_permission_without_admin?: false,
     has_permission_with_plugins?: false, has_permission_without_plugins?:
     false, memberships_by_role: Person.none, can_change_homepage?: false,
     can_control_scrap?: false, receives_scrap_notification?: false,
     can_control_activity?: false, can_post_content?: false,
     suggested_friend_groups: [], friend_groups: [], add_friend: nil,
     already_request_friendship?: false, remove_friend: nil,
     presence_of_required_fields: nil, active_fields: [], required_fields: [],
     signup_fields: [], default_set_of_blocks: [], default_set_of_boxes: [],
     default_set_of_articles: [], cell_phone: nil, comercial_phone: nil,
     nationality: nil, schooling: nil, contact_information: nil, sex: nil,
     birth_date: nil, jabber_id: nil, personal_website: nil, address_reference:
     nil, district: nil, schooling_status: nil, formation: nil,
     custom_formation: nil, area_of_study: nil, custom_area_of_study: nil,
     professional_activity: nil, organization_website: nil, organization: nil,
     photo: nil, city: nil, state: nil, country: nil, zip_code: nil,
     address_line2: nil, copy_communities_from: nil,
     has_organization_pending_tasks?: false, organizations_with_pending_tasks:
     Organization.none, pending_tasks_for_organization: Task.none,
     build_contact: nil, is_a_friend?: false, ask_to_join?: false, refuse_join:
     nil, blocks_to_expire_cache: [], cache_keys: [], communities_cache_key: '',
     friends_cache_key: '', manage_friends_cache_key: '',
     relationships_cache_key: '', is_member_of?: false, follows?: false,
     each_friend: nil, is_last_admin?: false, is_last_admin_leaving?: false,
     leave: nil, last_notification: nil, notification_time: 0, notifier: nil,
     remove_suggestion: nil, allow_invitation_from?: false,
     tracked_actions: ActionTracker::Record.none, follow: [],
     update_profile_circles: ProfileFollower.none, unfollow: ProfileFollower.none,
     remove_profile_from_circle: ProfileFollower.none, followed_profiles: Profile.none
    }

    derivated_methods = generate_derivated_methods(methods_and_responses)
    derivated_methods.merge(methods_and_responses)
  end

  def profile_instance_methods
    methods_and_responses = {
     role_assignments: RoleAssignment.none, favorite_enterprises:
     Enterprise.none, memberships: Profile.none, friendships: Profile.none,
     tasks: Task.none, suggested_profiles: ProfileSuggestion.none,
     suggested_people: ProfileSuggestion.none, suggested_communities:
     ProfileSuggestion.none, public_profile: true, nickname: nil, custom_footer:
     '', custom_header: '', address: '', zip_code: '', contact_phone: '',
     image_builder: nil, description: '', closed: false, template_id: nil, lat:
     nil, lng: nil, is_template: false, fields_privacy: {}, preferred_domain_id:
     nil, category_ids: [], country: '', city: '', state: '',
     national_region_code: '', redirect_l10n: false, notification_time: 0,
     custom_url_redirection: nil, email_suggestions: false,
     allow_members_to_invite: false, invite_friends_only: false, secret: false,
     profile_admin_mail_notification: false, redirection_after_login: nil,
     profile_activities: ProfileActivity.none, action_tracker_notifications:
     ActionTrackerNotification.none, tracked_notifications:
     ActionTracker::Record.none, scraps_received: Scrap.none, template:
     Profile.none, comments_received: Comment.none, email_templates:
     EmailTemplate.none, members: Profile.none, members_like: Profile.none,
     members_by: Profile.none, members_by_role: Profile.none, scraps:
     Scrap.none, welcome_page_content: nil, settings: {}, find_in_all_tasks:
     nil, top_level_categorization: {}, interests: Category.none, geolocation:
     '', country_name: '', pending_categorizations: [], add_category: false,
     create_pending_categorizations: false, top_level_articles: Article.none,
     valid_identifier: true, valid_template: false, create_default_set_of_boxes:
     true, copy_blocks_from: nil, default_template: nil,
     template_without_default: nil, template_with_default: nil, apply_template:
     false, iframe_whitelist: [], recent_documents: Article.none, last_articles:
     Article.none, is_validation_entity?: false, hostname: nil, own_hostname:
     nil, article_tags: {}, tagged_with: Article.none,
     insert_default_article_set: false, copy_articles_from: true,
     copy_article_tree: nil, copy_article?: false, add_member: false,
     remove_member: false, add_admin: false, remove_admin: false, add_moderator:
     false, display_info_to?: true, update_category_from_region: nil,
     accept_category?: false, custom_header_expanded: '',
     custom_footer_expanded: '', public?: true, themes: [], find_theme: nil,
     blogs: Blog.none, blog: nil, has_blog?: false, forums: Forum.none, forum:
     nil, has_forum?: false, admins: [], settings_field: {}, setting_changed:
     false, public_content: true, enable_contact?: false, folder_types: [],
     folders: Article.none, image_galleries: Article.none, image_valid: true,
     update_header_and_footer: nil, update_theme: nil, update_layout_template:
     nil, recent_actions: ActionTracker::Record.none, recent_notifications:
     ActionTracker::Record.none, more_active_label: _('no activity'),
     more_popular_label: _('no members'), profile_custom_image: nil,
     is_on_homepage?: false, activities: ProfileActivity.none,
     may_display_field_to?: true, may_display_location_to?: true, public_fields:
     {}, followed_by?: false, display_private_info_to?: true, can_view_field?:
     true, remove_from_suggestion_list: nil, layout_template: 'default',
     is_admin?: false, add_friend: false, follows?: false, is_a_friend?: false,
     already_request_friendship?: false, allow_followers: false,
     in_social_circle: false, in_circle: false
    }

    derivated_methods = generate_derivated_methods(methods_and_responses)
    derivated_methods.merge(methods_and_responses)
  end

  def method_missing(method, *args, &block)
    if person_instance_methods.keys.include?(method)
      return person_instance_methods[method]
    end
    if profile_instance_methods.keys.include? method
      return profile_instance_methods[method]
    end
  end

  def respond_to_missing?(method_name, include_private = false)
    person_instance_methods.keys.include?(method_name) ||
    profile_instance_methods.keys.include?(method_name) ||
    super
  end

  private

  def generate_derivated_methods(methods)
    derivated_methods = {}
    methods.keys.each do |method|
      derivated_methods[method.to_s.insert(-1, '?').to_sym] = false
      derivated_methods[method.to_s.insert(-1, '=').to_sym] = nil
    end
    derivated_methods
  end
end
