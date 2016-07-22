class AnalyticsPlugin::Visit < ApplicationRecord

  attr_accessible *self.column_names
  attr_accessible :profile

  belongs_to :profile
  has_many :page_views, class_name: 'AnalyticsPlugin::PageView', dependent: :destroy
  has_many :users_page_views, -> { loaded_users }, class_name: 'AnalyticsPlugin::PageView', dependent: :destroy

  scope :latest, -> { order 'updated_at DESC' }

  scope :with_users_page_views, -> {
    eager_load(:users_page_views).where.not analytics_plugin_page_views: {visit_id: nil}
  }
  scope :without_page_views, -> {
    eager_load(:page_views).where analytics_plugin_page_views: {visit_id: nil}
  }

  def first_page_view
    self.page_views.first
  end

  delegate :user, :initial_time, to: :first_page_view

end
