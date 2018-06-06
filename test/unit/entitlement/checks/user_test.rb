# encoding: UTF-8
require_relative "../../../test_helper"

class Entitlement::Checks::UserTest < ActiveSupport::TestCase
  def setup
    @user = create_user('user').person
    @check = Entitlement::Checks::User.new
  end

  attr_reader :user, :check

  should 'not entitle nil user' do
    refute check.entitles?(nil)
  end

  should 'entitle any user' do
    assert check.entitles?(user)
  end
end
