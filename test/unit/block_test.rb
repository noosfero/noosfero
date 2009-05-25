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

  should 'generate CSS class name' do
    block = Block.new
    block.class.expects(:name).returns('SomethingBlock')
    assert_equal 'something-block', block.css_class_name
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

  should 'have a visible setting' do
    b = Block.new
    assert b.visible?
    b.visible = false
    b.save
    assert !b.visible?
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

end
