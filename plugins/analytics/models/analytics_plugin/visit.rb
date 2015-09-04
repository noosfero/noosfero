class AnalyticsPlugin::Visit < ActiveRecord::Base

  attr_accessible *self.column_names
  attr_accessible :profile

  belongs_to :profile
  has_many :page_views, class_name: 'AnalyticsPlugin::PageView', dependent: :destroy

  default_scope -> { joins(:page_views).includes :page_views }

  scope :latest, -> { order 'analytics_plugin_page_views.request_started_at DESC' }

  def first_page_view
    self.page_views.first
  end

  delegate :user, :initial_time, to: :first_page_view

end
