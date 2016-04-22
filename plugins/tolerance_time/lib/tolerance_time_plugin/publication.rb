class ToleranceTimePlugin::Publication < ApplicationRecord

  belongs_to :target, :polymorphic => true
  validates_presence_of :target_id, :target_type
  validates_uniqueness_of :target_id, :scope => :target_type
  attr_accessible :target

  class << self
    def find_by_target(target)
      find_by_target_id_and_target_type(target.id, target.class.base_class.name)
    end
  end

  def expired?
    profile = (target.kind_of?(Article) ? target.profile : target.article.profile)
    profile_tolerance = ToleranceTimePlugin::Tolerance.find_by profile_id: profile.id
    content_tolerance = profile_tolerance ? profile_tolerance.content_tolerance : nil
    comment_tolerance = profile_tolerance ? profile_tolerance.comment_tolerance : nil
    if target.kind_of?(Article)
      tolerance_time = content_tolerance || 1.0/0
    elsif target.kind_of?(Comment)
      tolerance_time = comment_tolerance || 1.0/0
    else
      tolerance_time = 1.0/0
    end
    created_at.to_f.to_i+tolerance_time < Time.now.to_i
  end
end
