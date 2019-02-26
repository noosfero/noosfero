require_relative "../test_helper"

class FansBlockTest < ActiveSupport::TestCase

  should 'inherit from ProfileListBlock' do
    assert_kind_of ProfileListBlock, FansBlock.new
  end

  should 'declare its default title' do
    FansBlock.any_instance.stubs(:profile_count).returns(0)
    assert_not_equal ProfileListBlock.new.default_title, FansBlock.new.default_title
  end

  should 'describe itself' do
    assert_not_equal ProfileListBlock.description, FansBlock.description
  end

  should 'list owner fans' do
    owner = fast_create(Enterprise)
    block = FansBlock.new
    block.stubs(:owner).returns(owner)

    f1 = fast_create(Person)
    f2 = fast_create(Person)
    f3 = fast_create(Person)
    owner.fans << f1
    owner.fans << f2

    assert_equivalent [f1,f2], block.profiles
  end

  should 'respond to person as base_class' do
    assert_equal Person, FansBlock.new.send(:base_class)
  end

end

