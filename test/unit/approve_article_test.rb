require File.dirname(__FILE__) + '/../test_helper'

class ApproveArticleTest < ActiveSupport::TestCase

  def setup
    ActionMailer::Base.delivery_method = :test
    ActionMailer::Base.perform_deliveries = true
    ActionMailer::Base.deliveries = []
    @profile = create_user('test_user').person
  end
  attr_reader :profile

  should 'have name, reference article and profile' do
    article = fast_create(TextArticle, :profile_id => profile.id, :name => 'test article')

    a = ApproveArticle.create!(:name => 'test name', :article => article, :target => profile, :requestor => profile)

    assert_equal 'test name', a.name
    assert_equal article, a.article
    assert_equal profile, a.target
  end

  should 'create published article when finished' do
    article = fast_create(TextArticle, :profile_id => profile.id, :name => 'test article')
    a = ApproveArticle.create!(:name => 'test name', :article => article, :target => profile, :requestor => profile)

    assert_difference PublishedArticle, :count do
      a.finish
    end
  end

  should 'override target notification message method from Task' do
    p1 = profile
    p2 = create_user('testuser2').person
    task = AddFriend.new(:person => p1, :friend => p2)
    assert_nothing_raised NotImplementedError do
      task.target_notification_message
    end
  end

  should 'have parent if defined' do
    article = fast_create(TextArticle, :profile_id => profile.id, :name => 'test article')
    folder = profile.articles.create!(:name => 'test folder', :type => 'Folder')

    a = ApproveArticle.create!(:name => 'test name', :article => article, :target => profile, :requestor => profile, :article_parent_id => folder.id)

    assert_equal folder, a.article_parent
  end

  should 'not have parent if not defined' do
    article = fast_create(TextArticle, :profile_id => profile.id, :name => 'test article')

    a = ApproveArticle.create!(:name => 'test name', :article => article, :target => profile, :requestor => profile)

    assert_nil a.article_parent
  end

  should 'alert when reference article is removed' do
    article = profile.articles.create!(:name => 'test article')

    a = ApproveArticle.create!(:name => 'test name', :article => article, :target => profile, :requestor => profile)

    article.destroy
    a.reload

    assert_match /text was removed/, a.description
  end

  should 'preserve article_parent' do
    article = profile.articles.create!(:name => 'test article')
    a = ApproveArticle.new(:article_parent => article)

    assert_equal article, a.article_parent
  end

  should 'handle blank names' do
    article = profile.articles.create!(:name => 'test article')
    community = fast_create(Community, :name => 'test comm')
    a = ApproveArticle.create!(:name => '', :article => article, :target => community, :requestor => profile)

    assert_difference PublishedArticle, :count do
      a.finish
    end
  end

  should 'notify target if group is moderated' do
    article = fast_create(TextArticle, :profile_id => profile.id, :name => 'test article')
    community = Community.create!(:name => 'test comm', :moderated_articles => true)
    a = ApproveArticle.create!(:name => '', :article => article, :target => community, :requestor => profile)
    assert !ActionMailer::Base.deliveries.empty?
  end

  should 'not notify target if group is not moderated' do
    article = fast_create(TextArticle, :profile_id => profile.id, :name => 'test article')
    community = Community.create!(:name => 'test comm', :moderated_articles => false)
    a = ApproveArticle.create!(:name => '', :article => article, :target => community, :requestor => profile)
    assert ActionMailer::Base.deliveries.empty?
  end

  should 'copy the source from the original article' do
    article = fast_create(TextArticle, :profile_id => profile.id, :name => 'test article', :source => "sample-feed.com")
    community = fast_create(Community, :name => 'test comm')

    a = ApproveArticle.create!(:name => 'test name', :article => article, :target => community, :requestor => profile)
    a.finish

    assert_equal PublishedArticle.last.source, article.source
  end

end
