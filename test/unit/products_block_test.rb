require File.dirname(__FILE__) + '/../test_helper'

class ProductsBlockTest < ActiveSupport::TestCase

  def setup
    @block = ProductsBlock.new
  end
  attr_reader :block

  should 'be inherit from block' do
    assert_kind_of Block, block
  end

  should 'provide default title' do
    assert_not_equal Block.new.default_title, ProductsBlock.new.default_title
  end

  should 'provide default description' do
    assert_not_equal Block.description, ProductsBlock.description
  end

  should "list owner products" do

    enterprise = Enterprise.create!(:name => 'testenterprise', :identifier => 'testenterprise')
    enterprise.products.create!(:name => 'product one')
    enterprise.products.create!(:name => 'product two')

    block.expects(:products).returns(enterprise.products)

    content = block.content

    assert_tag_in_string content, :content => 'Products'

    assert_tag_in_string content, :tag => 'li', :attributes => { :class => 'product' }, :descendant => { :tag => 'a', :content => /product one/ }
    assert_tag_in_string content, :tag => 'li', :attributes => { :class => 'product' }, :descendant => { :tag => 'a', :content => /product two/ }

  end

  should 'point to all products in footer' do
    enterprise = Enterprise.create!(:name => 'testenterprise', :identifier => 'testenterprise')
    enterprise.products.create!(:name => 'product one')
    enterprise.products.create!(:name => 'product two')

    block.stubs(:owner).returns(enterprise)

    footer = block.footer

    assert_tag_in_string footer, :tag => 'a', :attributes => { :href => /\/catalog\/testenterprise$/ }, :content => 'View all products'
  end

  should 'list 4 random products by default' do
    enterprise = Enterprise.create!(:name => 'testenterprise', :identifier => 'testenterprise')
    enterprise.products.create!(:name => 'product one')
    enterprise.products.create!(:name => 'product two')
    enterprise.products.create!(:name => 'product three')
    enterprise.products.create!(:name => 'product four')
    enterprise.products.create!(:name => 'product five')

    block.stubs(:owner).returns(enterprise)

    assert_equal 4, block.products.size
  end

  should 'list all products if less than 4 by default' do
    enterprise = Enterprise.create!(:name => 'testenterprise', :identifier => 'testenterprise')
    enterprise.products.create!(:name => 'product one')
    enterprise.products.create!(:name => 'product two')
    enterprise.products.create!(:name => 'product three')

    block.stubs(:owner).returns(enterprise)

    assert_equal 3, block.products.size
  end


  should 'be able to set product_ids and have them listed' do
    enterprise = Enterprise.create!(:name => 'testenterprise', :identifier => 'testenterprise')

    p1 = enterprise.products.create!(:name => 'product one')
    p2 = enterprise.products.create!(:name => 'product two')
    p3 = enterprise.products.create!(:name => 'product three')
    p4 = enterprise.products.create!(:name => 'product four')
    p5 = enterprise.products.create!(:name => 'product five')

    block.stubs(:owner).returns(enterprise)

    block.product_ids = [p1, p3, p5].map(&:id)
    assert_equal [p1, p3, p5], block.products
  end

  should 'save product_ids' do
    enterprise = Enterprise.create!(:name => 'testenterprise', :identifier => 'testenterprise')
    p1 = enterprise.products.create!(:name => 'product one')
    p2 = enterprise.products.create!(:name => 'product two')

    block = ProductsBlock.new
    enterprise.boxes.first.blocks << block
    block.product_ids = [p1.id, p2.id]
    block.save!

    assert_equal [p1.id, p2.id], ProductsBlock.find(block.id).product_ids
  end

  should 'accept strings in product_ids but store integers' do
    block = ProductsBlock.new
    block.product_ids = [ '1', '2']
    assert_equal [1, 2], block.product_ids
  end

  should 'not repeat products' do
    enterprise = Enterprise.create!(:name => 'test_enterprise', :identifier => 'test_enterprise')
    p1 = enterprise.products.create!(:name => 'product one')
    p2 = enterprise.products.create!(:name => 'product two')
    p3 = enterprise.products.create!(:name => 'product three')
    p4 = enterprise.products.create!(:name => 'product four')

    block = ProductsBlock.new
    enterprise.boxes.first.blocks << block
    block.save!

    4.times do # to keep a minimal chance of false positive, its random after all
      assert_equivalent [p1, p2, p3, p4], block.products
    end
  end

end
