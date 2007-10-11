require File.dirname(__FILE__) + '/../test_helper'

class RegionTest < Test::Unit::TestCase

  should 'be a subclass of category' do
    assert_equal Category, Region.superclass
  end

  should 'have an array of validators' do
    region = Region.new
    assert_raise ActiveRecord::AssociationTypeMismatch do
      region.validators = [ 1 ]
    end
    assert_nothing_raised do
      region.validators = [ Organization.new ]
    end
  end

  should 'be able to search for possible validators by name' do
    flunk 'need to write this test'
  end

  should 'return search results without validators that are already associated to the current region' do
    flunk 'need to write this test'
  end

end
