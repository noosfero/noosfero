require_relative '../../test_helper'

class ProductCategoriesBlockTest < ActiveSupport::TestCase
  should 'have display option to show only on catalog' do
    assert ProductCategoriesBlock::DISPLAY_OPTIONS.include?('catalog_only')
  end

  should 'set display to catalog_only by default' do
    assert_equal 'catalog_only', ProductCategoriesBlock.new.display
  end

  should 'display block only on catalog if display is set to catalog_only' do
    enterprise = fast_create(Enterprise)
    box = fast_create(Box, owner_id: enterprise.id, owner_type: 'Profile')
    block = ProductCategoriesBlock.new
    block.box = box

    refute block.visible?(params: {controller: 'any_other'})
    assert block.visible?(params: {controller: 'products_plugin/catalog'})
  end
end
