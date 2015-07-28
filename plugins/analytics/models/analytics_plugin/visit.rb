class AnalyticsPlugin::Visit < ActiveRecord::Base

  attr_accessible *self.column_names
  attr_accessible :profile

  default_scope -> { includes :page_views }

  belongs_to :profile
  has_many :page_views, class_name: 'AnalyticsPlugin::PageView', dependent: :destroy

end
