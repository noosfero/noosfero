# encoding: UTF-8
require_relative "../test_helper"

class ModerateUserRegistrationTest < ActiveSupport::TestCase
  fixtures :users, :environments

  def test_should_on_perform_activate_user
    user = User.new(:login => 'lalala', :email => 'lalala@example.com', :password => 'test', :password_confirmation => 'test')
    user.save!
    environment = Environment.default
    t= ModerateUserRegistration.new
    t.user_id = user.id
    t.name = user.name
    t.author_name = user.name
    t.email = user.email
    t.target= environment
    t.save!
    refute user.activated?
    t.perform
    assert environment.users.find_by(id: user.id).activated?
  end
end
