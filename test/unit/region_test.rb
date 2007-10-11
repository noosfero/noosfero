require File.dirname(__FILE__) + '/../test_helper'

class RegionTest < Test::Unit::TestCase

  should 'be a subclass of category' do
    assert_equal Category, Region.superclass
  end
end
