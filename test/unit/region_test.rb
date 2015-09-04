require_relative "../test_helper"

class RegionTest < ActiveSupport::TestCase

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

  should 'has validator' do
    env = fast_create(Environment)
    region = fast_create(Region, :environment_id => env.id, :name => 'My Region')
    region.validators.create!(:name => 'Validator entity', :identifier => 'validator-entity')
    assert region.has_validator?
  end

  should 'has no validator' do
    env = fast_create(Environment)
    region = fast_create(Region, :environment_id => env.id, :name => 'My Region')
    refute region.has_validator?
  end

  should 'list regions with validators' do
    bahia = fast_create(Region, :name => 'Bahia')
    bahia.validators << fast_create(Enterprise, :name => 'Forum Baiano de Economia Solidaria', :identifier => 'ecosol-ba')

    sergipe = fast_create(Region, :name => 'Sergipe')
    # Sergipe has no validators

    assert_equivalent [bahia], Region.with_validators
  end

  should 'list each region with validatores only once' do
    bahia = fast_create(Region, :name => 'Bahia')
    2.times { |i| bahia.validators << fast_create(Enterprise, :name => "validator #{i}", :identifier => "validator-#{i}")}
    assert_equal [bahia], Region.with_validators
  end

end
