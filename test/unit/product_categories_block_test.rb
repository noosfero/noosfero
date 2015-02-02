require_relative "../test_helper"

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

  should 'have display option to show only on catalog' do
    assert ProductCategoriesBlock::DISPLAY_OPTIONS.include?('catalog_only')
  end

  should 'set display to catalog_only by default' do
    assert_equal 'catalog_only', ProductCategoriesBlock.new.display
  end

  should 'display block only on catalog if display is set to catalog_only' do
    enterprise = fast_create(Enterprise)
    box = fast_create(Box, :owner_id => enterprise.id, :owner_type => 'Profile')
    block = ProductCategoriesBlock.new
    block.box = box
    block.box.environment.enable('products_for_enterprises')

    assert !block.visible?(:params => {:controller => 'any_other'})
    assert block.visible?(:params => {:controller => 'catalog'})
  end
end
