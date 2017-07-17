require_relative '../test_helper'

class CaptchaControllerTest < ActionController::TestCase
  def setup
    @controller = CaptchaController.new
    @environment = Environment.default
    create_user_with_permission('adminuser', 'manage_environment_captcha', environment)
    login_as('adminuser')
  end

  attr_accessor :environment

  should 'update environment captcha metadata' do
    metadata = {:create_comment => 2, :new_contact => 3}
    post 'index', :captcha => metadata

    environment.reload
    assert_equal '2', environment.metadata['captcha']['create_comment']
    assert_equal '3', environment.metadata['captcha']['new_contact']
  end
end
