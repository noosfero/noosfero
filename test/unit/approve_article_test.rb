require File.dirname(__FILE__) + '/../test_helper'

class ApproveArticleTest < ActiveSupport::TestCase

  should 'have name, reference article and profile' do
    profile = create_user('test_user').person
    article = profile.articles.create!(:name => 'test article')

    a = ApproveArticle.create!(:name => 'test name', :article => article, :target => profile, :requestor => profile)

    assert_equal 'test name', a.name
    assert_equal article, a.article
    assert_equal profile, a.target
  end

  should 'create published article when finished' do
    profile = create_user('test_user').person
    article = profile.articles.create!(:name => 'test article')
    a = ApproveArticle.create!(:name => 'test name', :article => article, :target => profile, :requestor => profile)

    assert_difference PublishedArticle, :count do
      a.finish
    end
  end

  should 'override target notification message method from Task' do
    p1 = create_user('testuser1').person
    p2 = create_user('testuser2').person
    task = AddFriend.new(:person => p1, :friend => p2)
    assert_nothing_raised NotImplementedError do
      task.target_notification_message
    end
  end

  should 'have parent if defined' do
    profile = create_user('test_user').person
    article = profile.articles.create!(:name => 'test article')
    folder = profile.articles.create!(:name => 'test folder', :type => 'Folder')

    a = ApproveArticle.create!(:name => 'test name', :article => article, :target => profile, :requestor => profile, :article_parent_id => folder.id)

    assert_equal folder, a.article_parent
  end

  should 'not have parent if not defined' do
    profile = create_user('test_user').person
    article = profile.articles.create!(:name => 'test article')

    a = ApproveArticle.create!(:name => 'test name', :article => article, :target => profile, :requestor => profile)

    assert_nil a.article_parent
  end

  should 'alert when reference article is removed' do
    profile = create_user('test_user').person
    article = profile.articles.create!(:name => 'test article')

    a = ApproveArticle.create!(:name => 'test name', :article => article, :target => profile, :requestor => profile)

    article.destroy
    a.reload

    assert_match /text was removed/, a.description
  end

end
