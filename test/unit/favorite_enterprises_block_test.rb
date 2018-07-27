require_relative "../test_helper"

class FavoriteEnterprisesBlockTest < ActiveSupport::TestCase

  should 'inherit from ProfileListBlock' do
    assert_kind_of ProfileListBlock, FavoriteEnterprisesBlock.new
  end

  should 'declare its default title' do
    assert_not_equal ProfileListBlock.new.default_title, FavoriteEnterprisesBlock.new.default_title
  end

  should 'describe itself' do
    assert_not_equal ProfileListBlock.description, FavoriteEnterprisesBlock.description
  end

  should 'list owner favorite enterprises' do
    owner = fast_create(Person)
    block = FavoriteEnterprisesBlock.new
    block.stubs(:owner).returns(owner)

    e1 = fast_create(Enterprise)
    e2 = fast_create(Enterprise)
    e3 = fast_create(Enterprise)
    owner.favorite_enterprises << e1
    owner.favorite_enterprises << e2

    assert_equivalent [e1,e2], block.profiles
  end

  should 'have Enterprise as base_class' do
    assert_equal Enterprise, FavoriteEnterprisesBlock.new.send(:base_class)
  end

end
