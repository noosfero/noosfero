require_relative "../test_helper"

class ProductionCostTest < ActiveSupport::TestCase

  should 'have name' do
    p = ProductionCost.new
    p.valid?
    assert p.errors[:name.to_s].present?

    p.name = 'Taxes'
    p.valid?
    assert !p.errors[:name.to_s].present?
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
    assert p.errors[:name.to_s].present?

    p.name = 'a'*30
    p.valid?
    assert !p.errors[:name.to_s].present?
  end

  should 'not have duplicated name on same environment' do
    cost = create(ProductionCost, :name => 'Taxes', :owner => Environment.default)

    invalid_cost = build(ProductionCost, :name => 'Taxes', :owner => Environment.default)
    invalid_cost.valid?

    assert invalid_cost.errors[:name.to_s].present?
  end

  should 'not have duplicated name on same enterprise' do
    enterprise = fast_create(Enterprise)
    cost = create(ProductionCost, :name => 'Taxes', :owner => enterprise)

    invalid_cost = build(ProductionCost, :name => 'Taxes', :owner => enterprise)
    invalid_cost.valid?

    assert invalid_cost.errors[:name.to_s].present?
  end

  should 'not allow same name on enterprise if already has on environment' do
    enterprise = fast_create(Enterprise)

    cost1 = create(ProductionCost, :name => 'Taxes', :owner => Environment.default)
    cost2 = create(ProductionCost, :name => 'Taxes', :owner => enterprise)

    cost2.valid?

    assert !cost2.errors[:name.to_s].present?
  end

  should 'allow duplicated name on different enterprises' do
    enterprise = fast_create(Enterprise)
    enterprise2 = fast_create(Enterprise)

    cost1 = create(ProductionCost, :name => 'Taxes', :owner => enterprise)
    cost2 = build(ProductionCost, :name => 'Taxes', :owner => enterprise2)

    cost2.valid?

    assert !cost2.errors[:name.to_s].present?
  end

  should 'be associated to an environment as owner' do
    p = ProductionCost.new
    p.valid?
    assert p.errors[:owner.to_s].present?

    p.owner = Environment.default
    p.valid?
    assert !p.errors[:owner.to_s].present?
  end

  should 'be associated to an enterprise as owner' do
    enterprise = fast_create(Enterprise)
    p = ProductionCost.new
    p.valid?
    assert p.errors[:owner.to_s].present?

    p.owner = enterprise
    p.valid?
    assert !p.errors[:owner.to_s].present?
  end

  should 'create a production cost on an enterprise' do
    enterprise = fast_create(Enterprise)
    create(ProductionCost, :name => 'Energy', :owner => enterprise)
    assert_equal ['Energy'], enterprise.production_costs.map(&:name)
  end
end
