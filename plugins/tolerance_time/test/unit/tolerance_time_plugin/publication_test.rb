require 'test_helper'

class ToleranceTimePlugin::PublicationTest < ActiveSupport::TestCase
  should 'validate presence of target' do
    publication = ToleranceTimePlugin::Publication.new
    publication.valid?
    assert publication.errors[:target_id].present?
    assert publication.errors[:target_type].present?

    publication.target = fast_create(Article)
    publication.valid?

    refute publication.errors[:target_id].present?
    refute publication.errors[:target_type].present?
  end

  should 'validate uniqueness of target' do
    target = fast_create(Article)
    p1 = ToleranceTimePlugin::Publication.create!(:target => target)
    p2 = ToleranceTimePlugin::Publication.new(:target => target)
    p2.valid?

    assert p2.errors[:target_id].present?
  end

  should 'be able to find publication by target' do
    article = fast_create(Article)
    publication = ToleranceTimePlugin::Publication.create!(:target => article)
    assert_equal publication, ToleranceTimePlugin::Publication.find_by_target(article)
  end

  should 'avaliate if the publication is expired' do
    profile = fast_create(Profile)
    author = fast_create(Person)
    a1 = fast_create(Article, :profile_id => profile.id)
    a2 = fast_create(Article, :profile_id => profile.id)
    c1 = fast_create(Comment, :source_id => a1.id)
    c2 = fast_create(Comment, :source_id => a2.id)
    ToleranceTimePlugin::Tolerance.create!(:profile => profile, :content_tolerance => 10.minutes, :comment_tolerance => 5.minutes)
    expired_article = ToleranceTimePlugin::Publication.create!(:target => a1)
    expired_article.created_at = 15.minutes.ago
    expired_article.save!
    on_time_article = ToleranceTimePlugin::Publication.create!(:target => a2)
    on_time_article.created_at = 5.minutes.ago
    on_time_article.save!
    expired_comment = ToleranceTimePlugin::Publication.create!(:target => c1)
    expired_comment.created_at = 8.minutes.ago
    expired_comment.save!
    on_time_comment = ToleranceTimePlugin::Publication.create!(:target => c2)
    on_time_comment.created_at = 2.minutes.ago
    on_time_comment.save!

    assert expired_article.expired?
    refute on_time_article.expired?
    assert expired_comment.expired?
    refute on_time_comment.expired?
  end

  should 'consider tolerance infinity if not defined' do
    profile = fast_create(Profile)
    article = fast_create(Article, :profile_id => profile.id)
    article_publication = ToleranceTimePlugin::Publication.create!(:target => article)
    article_publication.created_at = 1000.years.ago
    article_publication.save!
    ToleranceTimePlugin::Tolerance.create!(:profile => profile)

    refute article_publication.expired?
  end

  should 'not crash if profile has no tolerance yet defined' do
    profile = fast_create(Profile)
    article = fast_create(Article, :profile_id => profile.id)
    article_publication = ToleranceTimePlugin::Publication.create!(:target => article)
    article_publication.created_at = 1000.years.ago
    article_publication.save!

    refute article_publication.expired?
  end
end
