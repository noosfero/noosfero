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

end
