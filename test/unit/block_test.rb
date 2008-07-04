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

  should 'not be editable by default' do
    assert !Block.new.editable?
  end

end
