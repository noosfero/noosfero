require File.dirname(__FILE__) + '/../test_helper'

class ApproveArticleTest < ActiveSupport::TestCase

  should 'have name, reference article and profile' do
    profile = create_user('test_user').person
    article = profile.articles.create!(:name => 'test article')

    a = ApproveArticle.create!(:name => 'test name', :article => article, :target => profile)

    assert_equal 'test name', a.name
    assert_equal article, a.article
    assert_equal profile, a.target
  end

  should 'create published article when finished' do
    profile = create_user('test_user').person
    article = profile.articles.create!(:name => 'test article')
    a = ApproveArticle.create!(:name => 'test name', :article => article, :target => profile)

    assert_difference PublishedArticle, :count do
      a.finish
    end

  end
end
