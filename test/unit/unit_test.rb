require_relative "../test_helper"

class UnitTest < ActiveSupport::TestCase

  should 'require singular name' do
    unit = Unit.new; unit.valid?
    assert_match /can't be blank/, unit.errors["singular"].first
  end

  should 'require plural name' do
    unit = Unit.new; unit.valid?
    assert_match /can't be blank/, unit.errors["plural"].first
  end

  should 'belongs and require an environment' do
    unit = Unit.new; unit.valid?
    assert_match /can't be blank/, unit.errors["environment_id"].first
    unit.environment = Environment.default; unit.valid?
    assert_nil unit.errors["environment_id"].first
  end

  should 'increment position automatically' do
    first = Unit.new(:singular => 'Litre', :plural => 'Litres').tap do |u|
      u.environment = Environment.default
      u.save!
    end
    second = Unit.new(:singular => 'Meter', :plural => 'Meters').tap do |u|
      u.environment = Environment.default
      u.save!
    end
    assert_equal 1, first.position
    assert_equal 2, second.position
  end

  should 'has an getter and setter alias to singular field' do
    unit = Unit.new(:name => 'Litre')
    assert_equal 'Litre', unit.singular
  end

end
