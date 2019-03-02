# encoding: UTF-8
require_relative "../../../../test_helper"

class Entitlement::Checks::Profile::SelfTest < ActiveSupport::TestCase
  def setup
    @user = create_user('user').person
    @person = fast_create(Person)
    @check = Entitlement::Checks::Profile::Self.new(@user)
  end

  attr_reader :user, :person, :check

  should 'not entitle nil user' do
    refute check.entitles?(nil)
  end

  should 'not entitle random user' do
    refute check.entitles?(person)
  end

  should 'entitle the user himself' do
    assert check.entitles?(user)
  end
end
