require File.dirname(__FILE__) + '/../test_helper'

class SetProfileRegionFromCityStateTest < ActiveSupport::TestCase

  def setup
    super
    TestSolr.enable
  end

  should 'set city and state from names' do
    s = State.create!(:name => 'Sao Paulo', :acronym => 'SP', :environment_id => Environment.default.id)
    c = City.create!(:name => 'Pindamonhangaba', :parent_id => s.id, :environment_id => Environment.default.id)
    p = fast_create(Person, :user_id => fast_create(User).id)
    p.state_with_region = 'SP'
    p.city_with_region = 'Pindamonhangaba'
    p.save!
    assert p.region == c
  end

  should 'set region to null if city not found' do
    s = State.create!(:name => 'Sao Paulo', :acronym => 'SP', :environment_id => Environment.default.id)
    p = fast_create(Person, :user_id => fast_create(User).id)
    p.state_with_region = 'SP'
    p.city_with_region = 'Pindamonhangaba'
    p.save!
    assert p.region.nil?
  end

  should 'set region to null if state not found' do
    s = State.create!(:name => 'Sao Paulo', :acronym => 'SP', :environment_id => Environment.default.id)
    c = City.create!(:name => 'Pindamonhangaba', :parent_id => s.id, :environment_id => Environment.default.id)
    p = fast_create(Person, :user_id => fast_create(User).id)
    p.state_with_region = 'RJ'
    p.city_with_region = 'Pindamonhangaba'
    p.save!
    assert p.region.nil?
  end
end
