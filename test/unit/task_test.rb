require File.dirname(__FILE__) + '/../test_helper'

class TaskTest < Test::Unit::TestCase

  def test_relationship_with_requestor
    t = Task.new
    assert_raise ActiveRecord::AssociationTypeMismatch do
      t.requestor = 1
    end
    assert_nothing_raised do
      t.requestor = Profile.new
    end
  end

  def test_relationship_with_target
    t = Task.new
    assert_raise ActiveRecord::AssociationTypeMismatch do
      t.target = 1
    end
    assert_nothing_raised do
      t.target = Profile.new
    end
  end
end
