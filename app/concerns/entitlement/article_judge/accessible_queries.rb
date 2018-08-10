module Entitlement::ArticleJudge::AccessibleQueries
  include Entitlement::AccessibleQueries

  def friendship_score_table
    'article_access_friendships'
  end

  def membership_score_table
    'article_access_memberships'
  end

  def privacy_exception_score_table
    'articles left join article_privacy_exceptions on article_privacy_exceptions.article_id = articles.id'
  end

  def privacy_exception_conditions(user)
    Entitlement::Checks::Article::Exception.filter_condition(user)
  end

  def score_kinds
    %w[friendship membership privacy_exception]
  end

  def profile_id_column
    'articles.profile_id'
  end
end
