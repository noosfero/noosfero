require File.dirname(__FILE__) + '/../test_helper'

class ProductCategoriesBlockTest < ActiveSupport::TestCase
  should 'not be visible if products are disabled on the environment ' do
    enterprise = fast_create(Enterprise)
    box = fast_create(Box, :owner_id => enterprise.id, :owner_type => 'Profile')
    block = ProductCategoriesBlock.new
    block.box = box

    block.box.environment.enable('products_for_enterprises')
    assert block.visible?

    block.box.environment.disable('products_for_enterprises')
    assert !block.visible?
  end
end
