require File.dirname(__FILE__) + '/test_helper'

class BlockTest < Test::Unit::TestCase

  include Design

  def test_position_validation
    b = Block.new
    u = DesignTestUser.new
    assert u.save
    box = Box.new
    box.owner = u 
    box.number = 1000
    assert box.save
    b.box = box
    assert !b.valid?
    assert b.errors.invalid?(:position)
    assert_equal 1, b.errors.length
  end

  def test_box_validation
    b = Block.new
    b.position=1

    assert !b.valid?
    assert b.errors.invalid?(:box_id)
    assert_equal 1, b.errors.length

  end

  def test_save
    b = Block.new
    b.position = 1000

    u = DesignTestUser.new
    assert u.save
    box = Box.new
    box.owner = u 
    box.number = 1000
    assert box.save
    b.box = box
    assert b.valid?

  end

  def test_main_should_always_return_false
    assert_equal false, Block.new.main?
  end

  def test_should_not_allow_content_in_block_superclass
    assert_raise ArgumentError do
      Block.new.content
    end
  end

end
