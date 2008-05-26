require File.dirname(__FILE__) + '/../test_helper'

class ProductSearchBlockTest < Test::Unit::TestCase

  should 'describe itself' do
    assert_not_equal Block.description, ProductSearchBlock.description
  end

  should 'titleize itself' do
    assert_not_nil ProductSearchBlock.title
  end

  should 'take block content'

end
