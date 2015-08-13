require 'test_helper'
require_relative '../../controllers/vote_plugin_profile_controller'

class VotePluginProfileControllerTest < ActionController::TestCase

  def setup
    @profile = create_user('profile').person
    @article = TinyMceArticle.create!(:profile => @profile, :name => 'An article')
    @comment = Comment.new(:source => @article, :author => @profile, :body => 'test')
    @comment.save!
    login_as(@profile.identifier)
    @environment = Environment.default
    @environment.enable_plugin(VotePlugin)
    self.stubs(:user).returns(@profile)
  end

  attr_reader :profile, :comment, :environment, :article

  should 'do not vote if user is not logged in' do
    logout
    xhr :post, :vote, :profile => profile.identifier, :id => comment.id, :model => 'comment', :vote => 1
    assert_response 401
  end

  should 'not vote if value is not allowed' do
    xhr :post, :vote, :profile => profile.identifier, :id => comment.id, :model => 'comment', :vote => 4
    refute profile.voted_on?(comment)
  end

  should 'not vote in a disallowed model' do
    xhr :post, :vote, :profile => profile.identifier, :id => environment.id, :model => 'environment', :vote => 1
    assert profile.votes.empty?
  end

  should 'like comment' do
    xhr :post, :vote, :profile => profile.identifier, :id => comment.id, :model => 'comment', :vote => 1
    assert profile.voted_for?(comment)
  end

  should 'unlike comment' do
    xhr :post, :vote, :profile => profile.identifier, :id => comment.id, :model => 'comment', :vote => 1
    xhr :post, :vote, :profile => profile.identifier, :id => comment.id, :model => 'comment', :vote => 1
    refute profile.voted_for?(comment)
  end

  should 'dislike comment' do
    xhr :post, :vote, :profile => profile.identifier, :id => comment.id, :model => 'comment', :vote => -1
    assert profile.voted_against?(comment)
  end

  should 'undislike comment' do
    xhr :post, :vote, :profile => profile.identifier, :id => comment.id, :model => 'comment', :vote => -1
    xhr :post, :vote, :profile => profile.identifier, :id => comment.id, :model => 'comment', :vote => -1
    refute profile.voted_against?(comment)
  end

  should 'dislike a liked comment' do
    xhr :post, :vote, :profile => profile.identifier, :id => comment.id, :model => 'comment', :vote => 1
    xhr :post, :vote, :profile => profile.identifier, :id => comment.id, :model => 'comment', :vote => -1
    assert profile.voted_against?(comment)
  end

  should 'like a disliked comment' do
    xhr :post, :vote, :profile => profile.identifier, :id => comment.id, :model => 'comment', :vote => -1
    xhr :post, :vote, :profile => profile.identifier, :id => comment.id, :model => 'comment', :vote => 1
    assert profile.voted_for?(comment)
  end

  should 'like article' do
    xhr :post, :vote, :profile => profile.identifier, :id => article.id, :model => 'article', :vote => 1
    assert profile.voted_for?(article)
  end

  should 'update views with new vote state' do
    xhr :post, :vote, :profile => profile.identifier, :id => article.id, :model => 'article', :vote => 1
    assert_select_rjs :replace do
      assert_select "#vote_article_#{article.id}_1"
      assert_select "#vote_article_#{article.id}_-1"
    end
  end

end
