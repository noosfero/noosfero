require File.dirname(__FILE__) + '/test_helper'

class BoxTest < Test::Unit::TestCase

  include Design

  def setup
    @owner = DesignTestUser.create!(:name => 'my test user')
  end

  def teardown
    Box.delete_all
    DesignTestUser.delete_all
  end

  def test_block_should_have_an_owner
    count = Box.count
    b = Box.new
    b.owner = @owner
    assert b.save
    assert count + 1,  Box.count
  end

  def test_should_only_accept_integers_as_number
    b = Box.new
    b.number = "none"
    assert !b.valid?
    assert b.errors.invalid?(:number)

    b = Box.new 
    b.owner = @owner
    b.number = 10.2
    assert !b.valid?
    assert b.errors.invalid?(:number)

    b = Box.new
    b.owner = @owner
    b.number = 10
    assert b.save
  end

  def test_should_require_unique_number
    b1 = Box.new
    b1.owner = @owner
    assert b1.save
   
    b2 = Box.new
    b2.owner = @owner
    b2.number = b1.number
    assert !b2.valid?
    assert b2.errors.invalid?(:number)
  end

  def test_should_require_presence_of_number
    b = Box.new(:number => nil)
    assert !b.valid?
    assert b.errors.invalid?(:number)
  end

end
