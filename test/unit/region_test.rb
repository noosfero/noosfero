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
    env = Environment.create!(:name => "my test environment")
    region = Region.create!(:environment_id => env.id, :name => 'My Region')
    org1 = Organization.create!(:name => 'Organization 1', :identifier => 'org1', :environment_id => env.id)
    org2 = Organization.create!(:name => 'Organization 2', :identifier => 'org2', :environment_id => env.id)

    possible = region.search_possible_validators('organization')
    assert possible.include?(org2)
    assert possible.include?(org1)
  end

  should 'return search results without validators that are already associated to the current region' do
    env = Environment.create!(:name => "my test environment")
    region = Region.create!(:environment_id => env.id, :name => 'My Region')
    org1 = Organization.create!(:name => 'Organization 1', :identifier => 'org1', :environment_id => env.id)
    org2 = Organization.create!(:name => 'Organization 2', :identifier => 'org2', :environment_id => env.id)
    region.validators << org1

    possible = region.search_possible_validators('organization')
    assert possible.include?(org2)
    assert !possible.include?(org1)
  end

end
