# encoding: UTF-8
require_relative "../../test_helper"

class Entitlement::LevelsTest < ActiveSupport::TestCase
  should 'return range_options' do
    assert_equal [:visitors, :users, :related, :self], Entitlement::Levels.range_options
    assert_equal [:users, :related, :self], Entitlement::Levels.range_options(1)
    assert_equal [:users, :related], Entitlement::Levels.range_options(1, 2)
  end

  should 'return base labels' do
    labels = Entitlement::Levels.labels(Profile.new)
    assert_equal 'Visitors', labels[:visitors]
    assert_equal 'Logged users', labels[:users]
    assert_equal 'Friends / Members', labels[:related]
    assert_equal 'Me / Administrators', labels[:self]
    assert_equal 'Nobody', labels[:nobody]
  end

  should 'return person labels' do
    labels = Entitlement::Levels.labels(Person.new)
    assert_equal 'Friends', labels[:related]
    assert_equal 'Me', labels[:self]
  end

  should 'return group labels' do
    labels = Entitlement::Levels.labels(Organization.new)
    assert_equal 'Members', labels[:related]
    assert_equal 'Administrators', labels[:self]
  end
end
