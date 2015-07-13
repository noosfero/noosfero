class ToleranceTimePlugin::Tolerance < ActiveRecord::Base

  belongs_to :profile
  validates_presence_of :profile_id
  validates_uniqueness_of :profile_id
  validates_numericality_of :content_tolerance, :only_integer => true, :allow_nil => true
  validates_numericality_of :comment_tolerance, :only_integer => true, :allow_nil => true
  attr_accessible :profile, :content_tolerance, :comment_tolerance

end
