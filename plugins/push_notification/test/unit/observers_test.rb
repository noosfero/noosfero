require 'test_helper'
require_relative '../helpers/observers_test_helper'

class ObserversTest < ActiveSupport::TestCase
  include ObserversTestHelper

  def setup
    environment = Environment.default
    environment.enable_plugin(PushNotificationPlugin)
  end

  should 'send notification when creating a comment' do
    PushNotificationPlugin.any_instance.expects(:send_to_users)
    person = fast_create(Person)
    article = fast_create(Article, :profile_id => person.id)
    Comment.create!(:author => person, :title => 'test comment', :body => 'body!', :source => article)
  end

  should 'send notification when adding a friend' do
    PushNotificationPlugin.any_instance.expects(:send_to_users)
    create_add_friend_task
  end

  should 'send notification when friendship is accepted' do
    PushNotificationPlugin.any_instance.expects(:send_to_users).twice
    create_add_friend_task.finish
  end

  should 'send notification when friendship is refused' do
    PushNotificationPlugin.any_instance.expects(:send_to_users).twice
    create_add_friend_task.cancel
  end

  should 'send notification when adding a member to a community' do
    PushNotificationPlugin.any_instance.expects(:send_to_users)
    create_add_member_task
  end

  should 'send notification when accepting a member in a community' do
    PushNotificationPlugin.any_instance.expects(:send_to_users).twice
    create_add_member_task.finish
  end

  should 'send notification when rejecting a member in a community' do
    PushNotificationPlugin.any_instance.expects(:send_to_users).twice
    create_add_member_task.cancel
  end

  should 'send notification when suggesting an article' do
    PushNotificationPlugin.any_instance.expects(:send_to_users).twice
    create_suggest_article_task
  end

  should 'send notification when accepting suggested article' do
    PushNotificationPlugin.any_instance.expects(:send_to_users).times(5)
    create_suggest_article_task.finish
  end

  should 'send notification when rejecting suggested article' do
    PushNotificationPlugin.any_instance.expects(:send_to_users).times(4)
    create_suggest_article_task.cancel
  end

  should 'send notification when an article needs to be approved' do
    PushNotificationPlugin.any_instance.expects(:send_to_users)
    create_approve_article_task
  end

  should 'send notification when an article is approved' do
    PushNotificationPlugin.any_instance.expects(:send_to_users).times(3)
    create_approve_article_task.finish
  end

  should 'send notification when an article is not approved' do
    PushNotificationPlugin.any_instance.expects(:send_to_users).times(2)
    create_approve_article_task.cancel
  end

  should 'send notification when an article is created' do
    PushNotificationPlugin.any_instance.expects(:send_to_users).twice
    community = fast_create(Community)
    person = fast_create(Person)
    Article.create!(:name => 'great article', :profile => community)
    Article.create!(:name => 'great article', :profile => person)
  end
end
