require File.dirname(__FILE__) + '/../test_helper'

class PersonTest < Test::Unit::TestCase
  fixtures :profiles, :users

  # Replace this with your real tests.
  def test_truth
    assert true
  end

  def test_can_have_user
    p = profiles(:johndoe)
    assert_kind_of User, p.user
  end

  def test_may_have_no_user
    p = profiles(:john_and_joe)
    assert_nil p.user
    assert p.valid?
  end

  def test_only_one_profile_per_user
    p1 = profiles(:johndoe)
    assert_equal users(:johndoe), p1.user
    
    p2 = Person.new
    p2.user = users(:johndoe)
    assert !p2.valid?
    assert p2.errors.invalid?(:user_id)
  end

  def test_several_profiles_without_user
    p1 = profiles(:john_and_joe)
    assert p1.valid?
    assert_nil p1.user

    p2 = Person.new
    assert !p2.valid?
    assert !p2.errors.invalid?(:user_id)
  end
end
