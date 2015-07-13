require 'test_helper'

class BscPlugin::ContractTest < ActiveSupport::TestCase
  def setup
    @contract = BscPlugin::Contract.new(:bsc => BscPlugin::Bsc.new, :client_name => 'Marvin')
  end

  attr_accessor :contract

  should 'validates presence of bsc' do
    contract.bsc = nil
    contract.valid?
    assert contract.errors.invalid?(:bsc)

    contract.bsc = BscPlugin::Bsc.new
    contract.valid?
    assert !contract.errors.invalid?(:bsc)
  end

  should 'associate contract with products through sales' do
    contract.save!
    product1 = fast_create(Product)
    product2 = fast_create(Product)
    sale1 = BscPlugin::Sale.create!(:product => product1, :contract => contract, :quantity => 3)
    sale2 = BscPlugin::Sale.create!(:product => product2, :contract => contract, :quantity => 5)

    assert_includes contract.products, product1
    assert_includes contract.products, product2
  end

  should 'have many enterprises' do
    contract.save!
    enterprise1 = fast_create(Enterprise)
    contract.enterprises << enterprise1
    enterprise2 = fast_create(Enterprise)
    contract.enterprises << enterprise2

    assert_includes contract.enterprises, enterprise1
    assert_includes contract.enterprises, enterprise2
  end

  should 'filter contracts by status' do
    bsc = BscPlugin::Bsc.new
    opened = BscPlugin::Contract::Status::OPENED
    negotiating = BscPlugin::Contract::Status::NEGOTIATING
    executing = BscPlugin::Contract::Status::EXECUTING
    closed = BscPlugin::Contract::Status::CLOSED
    contract1 = BscPlugin::Contract.create!(:bsc => bsc, :status => opened, :client_name => 'Marvin')
    contract2 = BscPlugin::Contract.create!(:bsc => bsc, :status => negotiating, :client_name => 'Marvin')
    contract3 = BscPlugin::Contract.create!(:bsc => bsc, :status => executing, :client_name => 'Marvin')
    contract4 = BscPlugin::Contract.create!(:bsc => bsc, :status => closed, :client_name => 'Marvin')

    opened_and_executing = BscPlugin::Contract.status([opened, executing])
    negotiating_and_closed = BscPlugin::Contract.status([negotiating, closed])
    all = BscPlugin::Contract.status([])

    assert_includes opened_and_executing, contract1
    assert_not_includes opened_and_executing, contract2
    assert_includes opened_and_executing, contract3
    assert_not_includes opened_and_executing, contract4

    assert_not_includes negotiating_and_closed, contract1
    assert_includes negotiating_and_closed, contract2
    assert_not_includes negotiating_and_closed, contract3
    assert_includes negotiating_and_closed, contract4

    assert_includes all, contract1
    assert_includes all, contract2
    assert_includes all, contract3
    assert_includes all, contract4
  end

  should 'sort contracts by date' do
    bsc = BscPlugin::Bsc.new
    contract1 = BscPlugin::Contract.create!(:bsc => bsc, :created_at => 2.day.ago, :client_name => 'Marvin')
    contract2 = BscPlugin::Contract.create!(:bsc => bsc, :created_at => 1.day.ago, :client_name => 'Marvin')
    contract3 = BscPlugin::Contract.create!(:bsc => bsc, :created_at => 3.day.ago, :client_name => 'Marvin')

    assert_equal [contract3, contract1, contract2], BscPlugin::Contract.sorted_by('created_at', 'asc')
  end

  should 'sort contracts by client name' do
    bsc = BscPlugin::Bsc.new
    contract1 = BscPlugin::Contract.create!(:bsc => bsc, :client_name => 'Marvim')
    contract2 = BscPlugin::Contract.create!(:bsc => bsc, :client_name => 'Adam')
    contract3 = BscPlugin::Contract.create!(:bsc => bsc, :client_name => 'Eva')

    assert_equal [contract2, contract3, contract1], BscPlugin::Contract.sorted_by('client_name', 'asc')
  end

  should 'return contract total price' do
    contract.save!
    price1 = 1
    quantity1 = 3
    price2 = 2
    quantity2 = 5
    total = price1*quantity1 + price2*quantity2
    product1 = fast_create(Product, :price => price1)
    product2 = fast_create(Product, :price => price2)
    sale1 = BscPlugin::Sale.create!(:product => product1, :contract => contract, :quantity => quantity1)
    sale2 = BscPlugin::Sale.create!(:product => product2, :contract => contract, :quantity => quantity2)

    contract.reload

    assert_equal total, contract.total_price
  end
end
