require File.dirname(__FILE__) + '/../test_helper'

class ProductionCostTest < ActiveSupport::TestCase

  should 'have name' do
    p = ProductionCost.new
    p.valid?
    assert p.errors.invalid?(:name)

    p.name = 'Taxes'
    p.valid?
    assert !p.errors.invalid?(:name)
  end

  should 'not validates name if it is blank' do
    p = ProductionCost.new

    p.valid?
    assert_equal 1, p.errors['name'].to_a.count
  end

  should 'not have a too long name' do
    p = ProductionCost.new

    p.name = 'a'*40
    p.valid?
    assert p.errors.invalid?(:name)

    p.name = 'a'*30
    p.valid?
    assert !p.errors.invalid?(:name)
  end

  should 'not have duplicated name on same environment' do
    cost = ProductionCost.create(:name => 'Taxes', :owner => Environment.default)

    invalid_cost = ProductionCost.new(:name => 'Taxes', :owner => Environment.default)
    invalid_cost.valid?

    assert invalid_cost.errors.invalid?(:name)
  end

  should 'not have duplicated name on same enterprise' do
    enterprise = fast_create(Enterprise)
    cost = ProductionCost.create(:name => 'Taxes', :owner => enterprise)

    invalid_cost = ProductionCost.new(:name => 'Taxes', :owner => enterprise)
    invalid_cost.valid?

    assert invalid_cost.errors.invalid?(:name)
  end

  should 'not allow same name on enterprise if already has on environment' do
    enterprise = fast_create(Enterprise)

    cost1 = ProductionCost.create(:name => 'Taxes', :owner => Environment.default)
    cost2 = ProductionCost.new(:name => 'Taxes', :owner => enterprise)

    cost2.valid?

    assert !cost2.errors.invalid?(:name)
  end

  should 'allow duplicated name on different enterprises' do
    enterprise = fast_create(Enterprise)
    enterprise2 = fast_create(Enterprise)

    cost1 = ProductionCost.create(:name => 'Taxes', :owner => enterprise)
    cost2 = ProductionCost.new(:name => 'Taxes', :owner => enterprise2)

    cost2.valid?

    assert !cost2.errors.invalid?(:name)
  end

  should 'be associated to an environment as owner' do
    p = ProductionCost.new
    p.valid?
    assert p.errors.invalid?(:owner)

    p.owner = Environment.default
    p.valid?
    assert !p.errors.invalid?(:owner)
  end

  should 'be associated to an enterprise as owner' do
    enterprise = fast_create(Enterprise)
    p = ProductionCost.new
    p.valid?
    assert p.errors.invalid?(:owner)

    p.owner = enterprise
    p.valid?
    assert !p.errors.invalid?(:owner)
  end

  should 'create a production cost on an enterprise' do
    enterprise = fast_create(Enterprise)
    enterprise.production_costs.create(:name => 'Energy')
    assert_equal ['Energy'], enterprise.production_costs.map(&:name)
  end
end
