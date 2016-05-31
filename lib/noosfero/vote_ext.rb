require_dependency 'models/vote'

class Vote

  validates_uniqueness_of :voteable_id, :scope => [:voteable_type, :voter_type, :voter_id], :unless => :allow_duplicate?

  def allow_duplicate?
    voter.blank?
  end

  validate :verify_target_archived

  def verify_target_archived
    if voteable.kind_of?(Article) || voteable.kind_of?(Comment)
      if voteable.archived?
        errors.add(:base, _("The target is achived and can't accept votes"))
        false
      end
    end
  end

end
