# encoding: UTF-8
require_relative "../test_helper"

class CaptchaTest < ActiveSupport::TestCase

  class Dummy
    include Captcha
  end

  def setup
    @dummy = Dummy.new
    @action = :some_action
    @environment = mock
    @user = mock
    @model = mock

  end

  attr_accessor :dummy, :action, :environment, :user, :model

  should 'not call recaptcha if it is not required' do
    environment.expects(:require_captcha?).returns(false)
    dummy.expects(:verify_recaptcha).never
    assert dummy.verify_captcha(action, model, user, environment)
  end

  should 'refute verification if recaptcha is not verified' do
    environment.expects(:require_captcha?).returns(true)
    dummy.expects(:verify_recaptcha).returns(false)
    refute dummy.verify_captcha(action, model, user, environment)
  end

  should 'accept verification if recaptcha is verified' do
    environment.expects(:require_captcha?).returns(true)
    dummy.expects(:verify_recaptcha).returns(true)
    assert dummy.verify_captcha(action, model, user, environment)
  end
end
