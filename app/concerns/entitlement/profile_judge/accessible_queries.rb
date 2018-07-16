module Entitlement::ProfileJudge::AccessibleQueries
  include Entitlement::AccessibleQueries

  def friendship_score_table
    'profile_access_friendships'
  end

  def membership_score_table
    'profile_access_memberships'
  end

  def score_kinds
    %w[friendship membership]
  end

  def profile_id_column
    'profiles.id'
  end
end
