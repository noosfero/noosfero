require 'test_helper'
require_relative '../../controllers/profile/vote_plugin_profile_controller'

class VotePluginProfileControllerTest < ActionDispatch::IntegrationTest

  def setup
    @profile = create_user('profile').person
    @article = TextArticle.create!(:profile => @profile, :name => 'An article')
    @comment = Comment.new(:source => @article, :author => @profile, :body => 'test')
    @comment.save!
    login_as_rails5(@profile.identifier)
    @environment = Environment.default
    @environment.enable_plugin(VotePlugin)
    self.stubs(:user).returns(@profile)
  end

  attr_reader :profile, :comment, :environment, :article

  should 'do not vote if user is not logged in' do
    logout_rails5
    post vote_plugin_profile_path(profile.identifier, :vote, comment), params: { :model => 'comment', :vote => 1}, xhr: true
    assert_response 401
  end

  should 'not vote if value is not allowed' do
   post vote_plugin_profile_path(profile.identifier, :vote, comment), params: { :model => 'comment', :vote => 4}, xhr: true
    refute profile.voted_on?(comment)
  end

  should 'not vote in a disallowed model' do
    post vote_plugin_profile_path(profile.identifier, :vote, environment), params: {:model => 'environment', :vote => 1}, xhr: true
    assert profile.votes.empty?
  end

  should 'not vote if a target is archived' do
    article = Article.create!(:profile => profile, :name => 'Archived article', :archived => false)
    comment = Comment.create!(:body => 'Comment test', :source => article, :author => profile)
    post vote_plugin_profile_path(profile.identifier, :vote, article), params: {:model => 'article', :vote => 1}, xhr: true
    assert !profile.votes.empty?

    article.update_attributes(:archived => true)
   post vote_plugin_profile_path(profile.identifier, :vote, comment), params: { :model => 'comment', :vote => 1}, xhr: true

    assert !profile.voted_for?(comment)
  end

  should 'like comment' do
   post vote_plugin_profile_path(profile.identifier, :vote, comment), params: { :model => 'comment', :vote => 1}, xhr: true
    assert profile.voted_for?(comment)
  end

  should 'unlike comment' do
   post vote_plugin_profile_path(profile.identifier, :vote, comment), params: { :model => 'comment', :vote => 1}, xhr: true
   post vote_plugin_profile_path(profile.identifier, :vote, comment), params: { :model => 'comment', :vote => 1}, xhr: true
    refute profile.voted_for?(comment)
  end

  should 'dislike comment' do
   post vote_plugin_profile_path(profile.identifier, :vote, comment), params: { :model => 'comment', :vote => -1}, xhr: true
    assert profile.voted_against?(comment)
  end

  should 'undislike comment' do
   post vote_plugin_profile_path(profile.identifier, :vote, comment), params: { :model => 'comment', :vote => -1}, xhr: true
   post vote_plugin_profile_path(profile.identifier, :vote, comment), params: { :model => 'comment', :vote => -1}, xhr: true
    refute profile.voted_against?(comment)
  end

  should 'dislike a liked comment' do
   post vote_plugin_profile_path(profile.identifier, :vote, comment), params: { :model => 'comment', :vote => 1}, xhr: true
   post vote_plugin_profile_path(profile.identifier, :vote, comment), params: { :model => 'comment', :vote => -1}, xhr: true
    assert profile.voted_against?(comment)
  end

  should 'like a disliked comment' do
   post vote_plugin_profile_path(profile.identifier, :vote, comment), params: { :model => 'comment', :vote => -1}, xhr: true
   post vote_plugin_profile_path(profile.identifier, :vote, comment), params: { :model => 'comment', :vote => 1}, xhr: true
    assert profile.voted_for?(comment)
  end

  should 'like article' do
    post vote_plugin_profile_path(profile.identifier, :vote, article), params: {:model => 'article', :vote => 1}, xhr: true
    assert profile.voted_for?(article)
  end
end
