require_relative '../test_helper'

class PushSubscriptionsControllerTest < ActionController::TestCase

  def setup
    @person = create_user.person
    login_as(@person.identifier)
  end
  attr_reader :person

  should 'create a new subscription' do
    assert_difference 'PushSubscription.count' do
      post :create, subscription: { endpoint: '/some',
                                    keys: { auth: '123', p256dh: '456' } }
    end
  end

  should 'update an existing subscription' do
    subscription = person.push_subscriptions.create endpoint: '/some',
                                                    keys: { auth: '123', p256dh: '456' }
    assert_no_difference 'PushSubscription.count' do
      post :create, subscription: { endpoint: '/some',
                                    keys: { auth: '789', p256dh: '333' } }
    end
    subscription.reload
    assert_equal '789', subscription.keys['auth']
    assert_equal '333', subscription.keys['p256dh']
  end

  should 'link a subscription with a profile' do
    assert_difference 'person.push_subscriptions.count' do
      post :create, subscription: { endpoint: '/some',
                                    keys: { auth: '123', p256dh: '456' } }
    end
  end

  should 'return a bad request response when the subscription is invalid' do
    post :create, subscription: { endpoint: '/some', keys: { auth: '123' } }
    assert_response :bad_request
  end

end
