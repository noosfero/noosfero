require File.dirname(__FILE__) + '/../test_helper'

class ProductsBlockTest < ActiveSupport::TestCase

  def setup
    @block = ProductsBlock.new
  end
  attr_reader :block

  should 'be inherit from block' do
    assert_kind_of Block, block
  end

  should "list owner's products" do

    enterprise = Enterprise.create!(:name => 'testenterprise', :identifier => 'testenterprise')
    enterprise.products.create!(:name => 'product one')
    enterprise.products.create!(:name => 'product two')

    block.stubs(:owner).returns(enterprise)


    content = block.content

    assert_tag_in_string content, :content => 'Products'

    assert_tag_in_string content, :tag => 'li', :attributes => { :class => 'product' }, :descendant => { :tag => 'a', :content => /product one/ }
    assert_tag_in_string content, :tag => 'li', :attributes => { :class => 'product' }, :descendant => { :tag => 'a', :content => /product two/ }

  end

end
