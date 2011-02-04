require File.dirname(__FILE__) + '/../test_helper'
require 'account_controller'
require 'exception_notification.rb'
ActionController::Base.send :include, ExceptionNotifiable
ExceptionNotifier.exception_recipients = ['admin@example.com', 'user@example.com']

class ExceptionNotificationTest < ActionController::IntegrationTest
  def setup
    ActionMailer::Base.delivery_method = :test
    ActionMailer::Base.perform_deliveries = true
    ActionMailer::Base.deliveries = []
    AccountController.any_instance.stubs(:signup).raises(RuntimeError)
    AccountController.any_instance.stubs(:local_request?).returns(false)
    AccountController.any_instance.stubs(:consider_all_requests_local).returns(false)
  end

  should 'deliver mail notification about exceptions' do
    assert_difference ActionMailer::Base.deliveries, :size do
      get '/account/signup'
    end
  end

  should 'deliver mails to addresses listed in Noosfero configuration noosfero.yml' do
    get '/account/signup'
    assert_includes ActionMailer::Base.deliveries.map(&:to).flatten, 'admin@example.com'
    assert_includes ActionMailer::Base.deliveries.map(&:to).flatten, 'user@example.com'
  end

  should 'render not found when try to access invalid url' do
    get '/profile/ze/tag/notexists'
    assert_template 'not_found.rhtml'
  end
end
