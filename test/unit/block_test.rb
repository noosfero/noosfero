require File.dirname(__FILE__) + '/../test_helper'

class BlockTest < Test::Unit::TestCase
  fixtures :blocks

  # Replace this with your real tests.
  def test_create
    count = Block.count 
    b = Block.new
    assert !b.valid?
    assert b.errors.invalid?(:box_id)
    assert b.errors.invalid?(:position)
    
    u = User.new
    assert u.save
    box = Box.new
    box.owner = u 
    box.number = 1000
    assert box.save
    b.box = box
    assert !b.valid?
    assert b.errors.invalid?(:position)

    b.position=1
    assert b.save

    assert_equal count + 1, Block.count
  end

  def test_box_presence
    b = Block.new
    b.position = 1000
    assert !b.valid?
    assert b.errors.invalid?(:box_id)

    u = User.new
    assert u.save
    box = Box.new
    box.owner = u 
    box.number = 1000
    assert box.save
    b.box = box
    assert b.valid?

  end

  def test_destroy
    b = Block.find(1)
    assert b.destroy 
  end

  def test_valid_fixtures
    Block.find(:all).each do |b|
      assert b.valid?
    end
  end

end
