require File.dirname(__FILE__) + '/../test_helper'

class UnitTest < ActiveSupport::TestCase

  should 'require singular name' do
    unit = Unit.new; unit.valid?
    assert_match /can't be blank/, unit.errors["singular"]
  end

  should 'require plural name' do
    unit = Unit.new; unit.valid?
    assert_match /can't be blank/, unit.errors["plural"]
  end

  should 'belongs and require an environment' do
    unit = Unit.new; unit.valid?
    assert_match /can't be blank/, unit.errors["environment_id"]
    unit.environment = Environment.default; unit.valid?
    assert_nil unit.errors["environment_id"]
  end

  should 'increment position automatically' do
    first = Unit.create!(:singular => 'Litre', :plural => 'Litres', :environment => Environment.default)
    second = Unit.create!(:singular => 'Meter', :plural => 'Meters', :environment => Environment.default)
    assert_equal 1, first.position
    assert_equal 2, second.position
  end

  should 'has an getter and setter alias to singular field' do
    unit = Unit.new(:name => 'Litre')
    assert_equal 'Litre', unit.singular
  end

end
