# encoding: UTF-8
require_relative "../../../../test_helper"

class Entitlement::Checks::Profile::FriendTest < ActiveSupport::TestCase
  def setup
    @person = fast_create(Person)
    @user = create_user('user').person
    @check = Entitlement::Checks::Profile::Friend.new(@person)
  end

  attr_reader :person, :user, :check

  should 'not entitle nil user' do
    refute check.entitles?(nil)
  end

  should 'not entitle random user' do
    refute check.entitles?(user)
  end

  should 'entitle person friend' do
    user.add_friend(person)
    assert check.entitles?(user)
  end
end
