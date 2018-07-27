# encoding: UTF-8
require_relative "../../../../test_helper"

class Entitlement::Checks::Profile::AdministratorTest < ActiveSupport::TestCase
  def setup
    @profile = fast_create(Profile)
    @user = create_user('user').person
    @check = Entitlement::Checks::Profile::Administrator.new(@profile)
  end

  attr_reader :profile, :user, :check

  should 'not entitle nil user' do
    refute check.entitles?(nil)
  end

  should 'not entitle random user' do
    refute check.entitles?(user)
  end

  should 'entitle profile admin' do
    profile.add_admin(user)
    assert check.entitles?(user)
  end

  should 'entitle environment admin' do
    profile.environment.add_admin(user)
    assert check.entitles?(user)
  end
end
