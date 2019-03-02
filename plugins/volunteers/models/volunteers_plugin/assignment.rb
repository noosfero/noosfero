class VolunteersPlugin::Assignment < ApplicationRecord

  attr_accessible :profile_id

  belongs_to :profile, optional: true
  belongs_to :period, class_name: 'VolunteersPlugin::Period', optional: true

  validates_presence_of :profile
  validates_presence_of :period
  validates_uniqueness_of :profile_id, scope: :period_id

end
