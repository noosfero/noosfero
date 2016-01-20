require_dependency 'models/vote'

class Vote

  validates_uniqueness_of :voteable_id, :scope => [:voteable_type, :voter_type, :voter_id], :unless => :allow_duplicate?

  def allow_duplicate?
    voter.blank?
  end

end
