require File.dirname(__FILE__) + '/../test_helper'

class BoxTest < Test::Unit::TestCase
  fixtures :boxes, :blocks

  def test_destroy
    count = Box.count
    assert Box.find(1).destroy
    assert_equal count - 1, Box.count
  end

  def test_create
    count = Box.count
    b = Box.new
    b.number = 2
    assert b.save
    assert count + 1,  Box.count
  end


  def test_number_format
    b = Box.new
    b.number = "none"
    assert !b.valid?
    assert b.errors.invalid?(:number)

    b = Box.new
    b.number = 10.2
    assert !b.save

    b = Box.new
    b.number = 10
    assert b.save

  end

  def test_unique_number
    assert Box.delete_all
    assert Box.create(:number => 1)  
   
    b = Box.new(:number => 1)
    assert !b.valid?
    assert b.errors.invalid?(:number)
  end

end
