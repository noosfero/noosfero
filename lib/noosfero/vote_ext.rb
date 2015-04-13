require_dependency 'models/vote'

class Vote

  validates_uniqueness_of :voteable_id, :scope => [:voteable_type, :voter_type, :voter_id], :if => :allow_duplicated_vote?

  def allow_duplicated_vote?
    voter.present?
  end

end
