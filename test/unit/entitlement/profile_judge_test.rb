# encoding: UTF-8
require_relative "../../test_helper"

class Entitlement::ProfileJudgeTest < ActiveSupport::TestCase
  def setup
    @profile = Profile.new
  end

  attr_reader :profile

  should 'define access requirement as self if profile not visible' do
    profile.visible = false
    assert_equal Entitlement::Levels.levels[:self], profile.access_requirement
  end

  should 'define access requirement as related if profile is secret' do
    profile.secret = true
    assert_equal Entitlement::Levels.levels[:related], profile.access_requirement
  end

  should 'define access requirement as self if profile is secret and defines it' do
    profile.secret = true
    profile.access = Entitlement::Levels.levels[:self]
    assert_equal Entitlement::Levels.levels[:self], profile.access_requirement
  end

  should 'define access requirement as access if profile is visible and not secret' do
    assert_equal profile.access, profile.access_requirement
  end

  should 'define wall requirements as wall_access' do
    assert_equal profile.wall_access, profile.wall_requirement
  end

  should 'define menu_block requirement as users if person' do
    person = Person.new
    assert_equal Entitlement::Levels.levels[:users], person.menu_block_requirement
  end

  should 'define menu_block requirement as visitors if organization' do
    person = Organization.new
    assert_equal Entitlement::Levels.levels[:visitors], person.menu_block_requirement
  end
end
