require File.dirname(__FILE__) + '/../test_helper'

class ProfileCategorizationTest < ActiveSupport::TestCase

  should 'have profile and category' do
    person = create_user('test_user').person
    cat = Environment.default.categories.build(:name => 'a category'); cat.save!
    person.categories << cat
    person.save!
    assert_includes person.categories, cat
    assert_includes cat.people, person
    assert_equal [cat.id], person.category_ids 
  end

  should 'create instances for the entire hierarchy' do
    c1 = Category.create!(:name => 'c1', :environment => Environment.default)
    c2 = c1.children.create!(:name => 'c2', :environment => Environment.default)

    p = create_user('testuser').person

    assert_difference ProfileCategorization, :count, 2 do
      ProfileCategorization.create!(:category => c2, :profile => p)
    end

    assert_equal 2, ProfileCategorization.find_all_by_profile_id(p.id).size
  end

  should 'not duplicate entry for category that is parent of two others' do
    c1 = Category.create!(:name => 'c1', :environment => Environment.default)
    c2 = c1.children.create!(:name => 'c2', :environment => Environment.default)
    c3 = c1.children.create!(:name => 'c3', :environment => Environment.default)

    p = create_user('testuser').person

    assert_difference ProfileCategorization, :count, 3 do
      ac = ProfileCategorization.create!(:category => c2, :profile => p)
      ac = ProfileCategorization.create!(:category => c3, :profile => p)
    end
  end

  should 'remove all instances for a given profile' do
    c1 = Category.create!(:name => 'c1', :environment => Environment.default)
    c2 = c1.children.create!(:name => 'c2', :environment => Environment.default)
    c3 = c1.children.create!(:name => 'c3', :environment => Environment.default)

    p = create_user('testuser').person

    ac = ProfileCategorization.create!(:category => c2, :profile => p)
    ac = ProfileCategorization.create!(:category => c3, :profile => p)

    assert_difference ProfileCategorization, :count, -3 do
      ProfileCategorization.remove_all_for(p)
    end
  end

end
