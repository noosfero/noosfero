require_relative "../test_helper"

class CategoriesBlockTest < ActiveSupport::TestCase

  should 'default describe' do
    assert_not_equal Block.description, CategoriesBlock.description
  end

  should 'default title' do
    block = Block.new
    category_block =  CategoriesBlock.new
    assert_not_equal block.title, category_block.default_title
  end

  should 'have a help defined' do
    category_block =  CategoriesBlock.new
    assert_not_nil category_block.help
  end

  include BoxesHelper

  should 'display category block' do
    block = CategoriesBlock.new

    self.expects(:render).with(template: 'blocks/categories', locals: {block: block})
    render_block_content(block)
  end

  should 'be editable' do
    assert CategoriesBlock.new.editable?
  end

  should 'default category types is an empty array' do
    category_block = CategoriesBlock.new
    assert_kind_of Array, category_block.category_types
    assert category_block.category_types.empty?
  end

end
