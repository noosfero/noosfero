require 'test_helper'

class ArticleTest < ActiveSupport::TestCase
  should 'create a publication after publishing the article' do
    article = fast_create(Article, :published => false, :profile_id => fast_create(Profile).id)
    assert_nil ToleranceTimePlugin::Publication.find_by_target(article)

    article.published = true
    article.save!
    assert_not_nil ToleranceTimePlugin::Publication.find_by_target(article)
  end

  should 'destroy publication if the article is destroyed' do
    profile = fast_create(Profile)
    article = fast_create(Article, :profile_id => profile.id)
    article_publication = ToleranceTimePlugin::Publication.create!(:target => article)
    article.destroy
    assert_raise ActiveRecord::RecordNotFound do
      article_publication.reload
    end
  end

  should 'destroy publication if the article is changed to not published' do
    profile = fast_create(Profile)
    article = fast_create(Article, :profile_id => profile.id)
    article_publication = ToleranceTimePlugin::Publication.create!(:target => article)
    article.published = false
    article.save!
    assert_raise ActiveRecord::RecordNotFound do
      article_publication.reload
    end
  end
end
