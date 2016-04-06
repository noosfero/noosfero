require_relative '../../lib/push_notification_helper.rb'
require 'test_helper'

class PushNotificationPluginTest < ActiveSupport::TestCase
  include  PushNotificationHelper

  def setup
    environment = Environment.default
    environment.enable_plugin(PushNotificationPlugin)
  end

  should 'subscribe and unsubscribe to notification' do
    class AnyClass
      def self.push_notification_new_comment_additional_users
        ['YO']
      end
    end

    assert PushNotificationPlugin::subscribe(Environment.default, "new_comment", AnyClass)
    assert_equivalent PushNotificationPlugin::subscribers(Environment.default, "new_comment"), [AnyClass.name.constantize]
    assert PushNotificationPlugin::unsubscribe(Environment.default, "new_comment", AnyClass)
    assert_empty PushNotificationPlugin::subscribers(Environment.default, "new_comment")
  end

  should 'get additional users from subscribers' do
    class AnyClass
      def self.push_notification_new_comment_additional_users
        ['YO']
      end
    end

    PushNotificationPlugin::subscribe(Environment.default, "new_comment", AnyClass)
    AnyClass.expects(:push_notification_new_comment_additional_users).returns(['YO'])
    subscribers_additional_users("new_comment", Environment.default)
  end

  should 'return nill for unknown notification subscription methods' do
    class AnyEventCallbackClass
      def self.push_notification_any_event_additional_users
        ['YO']
      end
    end

    assert_nil PushNotificationPlugin::subscribe(Environment.default, "any_event", AnyEventCallbackClass)
    assert_nil PushNotificationPlugin::unsubscribe(Environment.default, "any_event", AnyEventCallbackClass)
    assert_nil PushNotificationPlugin::subscribers(Environment.default, "any_event")
  end

  should 'return empty list for known notification without subscribers' do
    class CommentCallbackClass
      def self.push_notification_new_comment_additional_users
        ['YO']
      end
    end

    refute PushNotificationPlugin::unsubscribe(Environment.default, "new_comment", CommentCallbackClass)
    assert_empty PushNotificationPlugin::subscribers(Environment.default, "new_comment")
  end

  should 'not subscribe to notification if correspondent method callback is not implemented' do
    class NoCallbackClass
    end

    assert_nil PushNotificationPlugin::subscribe(Environment.default, "new_comment", NoCallbackClass)
    assert_empty PushNotificationPlugin::subscribers(Environment.default, "new_comment")
  end

end
