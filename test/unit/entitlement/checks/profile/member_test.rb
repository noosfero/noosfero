# encoding: UTF-8
require_relative "../../../../test_helper"

class Entitlement::Checks::Profile::MemberTest < ActiveSupport::TestCase
  def setup
    @group = fast_create(Organization)
    @user = create_user('user').person
    @check = Entitlement::Checks::Profile::Member.new(@group)
  end

  attr_reader :group, :user, :check

  should 'not entitle nil user' do
    refute check.entitles?(nil)
  end

  should 'not entitle random user' do
    refute check.entitles?(user)
  end

  should 'entitle group member' do
    group.add_member(user)
    assert check.entitles?(user)
  end
end
