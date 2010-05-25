require File.dirname(__FILE__) + '/../test_helper'

class BlockTest < Test::Unit::TestCase

  should 'describe itself' do
    assert_kind_of String, Block.description
  end
  
  should 'access owner through box' do
    user = create_user('testinguser').person

    box = Box.create!(:owner => user)

    block = Block.new
    block.box = box
    block.save!

    assert_equal user, block.owner
  end

  should 'have no owner when there is no box' do
    assert_nil Block.new.owner
  end

  should 'provide no footer by default' do
    assert_nil Block.new.footer
  end

  should 'provide an empty default title' do
    assert_equal '', Block.new.default_title
  end

  should 'be editable by default' do
    assert Block.new.editable?
  end

  should 'have default titles' do
    b = Block.new
    b.expects(:default_title).returns('my title')
    assert_equal 'my title', b.title
  end

  should 'have default view_title ' do
    b = Block.new
    b.expects(:title).returns('my title')
    assert_equal 'my title', b.view_title
  end

  should 'be cacheable' do
    b = Block.new
    assert b.cacheable?
  end

  should 'provide chache keys' do
     p = create_user('test_user').person
     box = p.boxes[0]
     b = Block.create!(:box => box)

     assert_equal( "block-id-#{b.id}", b.cache_keys)
  end

  should 'list enabled blocks' do
    block1 = Block.create!(:title => 'test 1')
    block2 = Block.create!(:title => 'test 2', :enabled => false)
    assert_includes Block.enabled, block1
    assert_not_includes Block.enabled, block2
  end

  should 'be displayed everywhere by default' do
    assert_equal true, Block.new.visible?
  end

  should 'not display when set to hidden' do
    assert_equal false, Block.new(:display => 'never').visible?
    assert_equal false, Block.new(:display => 'never').visible?(:article => Article.new)
  end

  should 'be able to be displayed only in the homepage' do
    profile = Profile.new
    home_page = Article.new
    profile.home_page = home_page
    block = Block.new(:display => 'home_page_only')
    block.stubs(:owner).returns(profile)

    assert_equal true, block.visible?(:article => home_page)
    assert_equal false, block.visible?(:article => Article.new)
  end

  should 'be able to save display setting' do
    user = create_user('testinguser').person
    box = fast_create(Box, :owner_id => user.id)
    block = Block.create!(:display => 'never', :box => box)
    block.reload
    assert_equal 'never', block.display
  end

  should 'be able to update display setting' do
    user = create_user('testinguser').person
    box = fast_create(Box, :owner_id => user.id)
    block = Block.create!(:display => 'never', :box => box)
    assert block.update_attributes!(:display => 'always')
    block.reload
    assert_equal 'always', block.display
  end

end
