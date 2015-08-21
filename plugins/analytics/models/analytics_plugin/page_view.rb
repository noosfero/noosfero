class AnalyticsPlugin::PageView < ActiveRecord::Base

  serialize :data

  attr_accessible *self.column_names
  attr_accessible :user, :profile

  attr_accessor :request
  attr_accessible :request

  acts_as_having_settings field: :options

  belongs_to :visit, class_name: 'AnalyticsPlugin::Visit'
  belongs_to :referer_page_view, class_name: 'AnalyticsPlugin::PageView'

  belongs_to :user, class_name: 'Person'
  belongs_to :session, primary_key: :session_id, foreign_key: :session_id, class_name: 'Session'
  belongs_to :profile

  validates_presence_of :visit
  validates_presence_of :request, on: :create
  validates_presence_of :url

  before_validation :extract_request_data, on: :create
  before_validation :fill_referer_page_view, on: :create
  before_validation :fill_visit, on: :create

  scope :latest, -> { order 'request_started_at DESC' }

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

  def page_load!
    self.page_loaded_at = Time.now
    self.update_column :page_loaded_at, self.page_loaded_at
  end

  def increase_time_on_page!
    now = Time.now
    return unless now > self.initial_time

    self.time_on_page = now - self.initial_time
    self.update_column :time_on_page, self.time_on_page
  end

  protected

  def extract_request_data
    self.url = self.request.url.sub /\/+$/, ''
    self.referer_url = self.request.referer
    self.user_agent = self.request.headers['User-Agent']
    self.request_id = self.request.env['action_dispatch.request_id']
    self.remote_ip = self.request.remote_ip
  end

  def fill_referer_page_view
    self.referer_page_view = AnalyticsPlugin::PageView.order('request_started_at DESC').
      where(url: self.referer_url, session_id: self.session_id, user_id: self.user_id, profile_id: self.profile_id).first if self.referer_url.present?
  end

  def fill_visit
    self.visit = self.referer_page_view.visit if self.referer_page_view and self.referer_page_view.user_on_page?
    self.visit ||= AnalyticsPlugin::Visit.new profile: profile
  end

end

