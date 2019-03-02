require_relative '../test_helper'

class WebPushTest < ActiveSupport::TestCase

  should 'notify send a notification for every user subscription' do
    recipient = mock
    recipient.stubs(:push_subscriptions).returns([mock, mock])
    WebPush.expects(:notify).times(4)
    WebPush.notify_users([recipient, recipient], {})
  end

  should 'send a webpush payload when sending a notification' do
    subscription = mock
    subscription.stubs(:endpoint)
    subscription.stubs(:keys).returns({})
    subscription.stubs(:subject)
    Webpush.expects(:payload_send).once
    WebPush.notify(subscription, {})
  end

  should 'destroy the subscription when it raises InvalidSubscription' do
    subscription = mock
    subscription.stubs(:endpoint)
    subscription.stubs(:keys).returns({})
    subscription.stubs(:subject)

    resp = mock
    resp.stubs(:body)
    subscription.expects(:destroy).once
    Webpush.expects(:payload_send).raises(Webpush::InvalidSubscription.new(resp, "myhost"))
    WebPush.notify(subscription, {})
  end

end
