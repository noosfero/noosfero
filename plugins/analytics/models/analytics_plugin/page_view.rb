class AnalyticsPlugin::PageView < ApplicationRecord

  serialize :data

  attr_accessible *self.column_names
  attr_accessible :user, :profile

  attr_accessor :request
  attr_accessible :request

  acts_as_having_settings field: :options

  belongs_to :profile, validate: true
  belongs_to :visit, class_name: 'AnalyticsPlugin::Visit', touch: true, validate: true

  belongs_to :referer_page_view, class_name: 'AnalyticsPlugin::PageView', validate: false

  belongs_to :user, class_name: 'Person', validate: false
  belongs_to :session, primary_key: :session_id, foreign_key: :session_id, class_name: 'Session', validate: false

  validates :request, presence: true, on: :create
  validates :url, presence: true

  before_validation :extract_request_data, on: :create
  before_validation :fill_referer_page_view, on: :create
  before_validation :fill_visit, on: :create
  before_validation :fill_is_bot, on: :create

  after_update :destroy_empty_visit
  after_destroy :destroy_empty_visit

  scope :in_sequence, -> { order 'analytics_plugin_page_views.request_started_at ASC' }

  scope :page_loaded, -> { where 'analytics_plugin_page_views.page_loaded_at IS NOT NULL' }
  scope :not_page_loaded, -> { where 'analytics_plugin_page_views.page_loaded_at IS NULL' }

  scope :no_bots, -> { where.not is_bot: true }
  scope :bots, -> { where is_bot: true }

  scope :loaded_users, -> { in_sequence.page_loaded.no_bots }

  def request_duration
    self.request_finished_at - self.request_started_at
  end

  def initial_time
    self.page_loaded_at || self.request_finished_at
  end

  def user_last_time_seen
    self.initial_time + self.time_on_page
  end

  def user_on_page?
    Time.now < self.user_last_time_seen + AnalyticsPlugin::TimeOnPageUpdateInterval
  end

  def page_load! time
    self.page_loaded_at = time
    self.update_column :page_loaded_at, self.page_loaded_at
  end

  def increase_time_on_page!
    now = Time.now
    return unless now > self.initial_time

    self.time_on_page = now - self.initial_time
    self.update_column :time_on_page, self.time_on_page
  end

  def find_referer_page_view
    return if self.referer_url.blank?
    AnalyticsPlugin::PageView.order('request_started_at DESC').
      where(url: self.referer_url, session_id: self.session_id, user_id: self.user_id, profile_id: self.profile_id).first
  end

  def browser
    @browser ||= Browser.new self.user_agent
  end

  protected

  def extract_request_data
    self.url = self.request.url.sub /\/+$/, ''
    self.referer_url = self.request.referer
    self.user_agent = self.request.headers['User-Agent']
    self.request_id = self.request.env['action_dispatch.request_id']
    self.remote_ip = self.request.remote_ip
    true
  end

  def fill_referer_page_view
    self.referer_page_view = self.find_referer_page_view
    true
  end

  def fill_visit
    self.visit = self.referer_page_view.visit if self.referer_page_view and self.referer_page_view.user_on_page?
    self.visit ||= AnalyticsPlugin::Visit.new profile: profile
    true
  end

  def fill_is_bot
    self.is_bot = self.browser.bot?
    true
  end

  def destroy_empty_visit
    return unless self.visit_id_changed?
    old_visit = AnalyticsPlugin::Visit.find self.visit_id_was
    old_visit.destroy if old_visit.page_views.empty?
  end

end

