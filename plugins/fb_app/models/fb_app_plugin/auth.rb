class FbAppPlugin::Auth < OauthClientPlugin::Auth

  module Status
    Connected = 'connected'
    NotAuthorized = 'not_authorized'
    Unknown = 'unknown'
  end

  settings_items :signed_request
  settings_items :fb_user

  attr_accessible :provider_user_id, :signed_request

  before_create :update_user
  before_create :exchange_token
  after_create :schedule_exchange_token
  after_destroy :destroy_page_tabs
  before_validation :set_enabled

  validates_presence_of :provider_user_id
  validates_uniqueness_of :provider_user_id, scope: :profile_id

  def self.parse_signed_request signed_request, credentials = FbAppPlugin.page_tab_app_credentials
    secret = credentials[:secret] rescue ''
    request = Facebook::SignedRequest.new signed_request, secret: secret
    request.data
  end

  def status
    if self.access_token.present? and self.not_expired? then Status::Connected else Status::NotAuthorized end
  end
  def not_authorized?
    self.status == Status::NotAuthorized
  end
  def connected?
    self.status == Status::Connected
  end

  def exchange_token
    app_id = FbAppPlugin.timeline_app_credentials[:id]
    app_secret = FbAppPlugin.timeline_app_credentials[:secret]
    fb_auth = FbGraph2::Auth.new app_id, app_secret
    fb_auth.fb_exchange_token = self.access_token

    access_token = fb_auth.access_token!
    self.access_token = access_token.access_token
    self.expires_in = access_token.expires_in
    # refresh user and its stored access token
    self.fetch_user
  end

  def exchange_token!
    self.exchange_token
    self.save!
  end

  def signed_request_data
    self.class.parse_signed_request self.signed_request
  end

  def fetch_user
    fb_user = FbGraph2::User.me self.access_token
    self.fb_user = fb_user.fetch
  end
  def update_user
    self.fb_user = self.fetch_user
  end

  protected

  def destroy_page_tabs
    self.profile.fb_app_page_tabs.destroy_all
  end

  def exchange_token_and_reschedule!
    self.exchange_token!
    self.schedule_exchange_token
  end

  def schedule_exchange_token
    self.delay(run_at: self.expires_at - 2.weeks).exchange_token_and_reschedule!
  end

  def set_enabled
    self.enabled = self.not_expired?
  end

end

