class VolunteersPlugin::Period < ActiveRecord::Base

  attr_accessible :name
  attr_accessible :start, :end
  attr_accessible :owner_type
  attr_accessible :minimum_assigments
  attr_accessible :maximum_assigments

  belongs_to :owner, polymorphic: true

  has_many :assignments, class_name: 'VolunteersPlugin::Assignment', foreign_key: :period_id, include: [:profile], dependent: :destroy

  validates_presence_of :owner
  validates_presence_of :name
  validates_presence_of :start, :end

  extend OrdersPlugin::DateRangeAttr::ClassMethods
  date_range_attr :start, :end

  extend SplitDatetime::SplitMethods
  split_datetime :start
  split_datetime :end

end
