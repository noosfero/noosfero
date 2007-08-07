require File.dirname(__FILE__) + '/../test_helper'

class OrganizationTest < Test::Unit::TestCase
  fixtures :profiles

  # FIXME: add actual organization tests here
  def test_truth
    assert_not_nil Organization.new
  end
end
