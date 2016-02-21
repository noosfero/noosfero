require_relative "../test_helper"

class ProfileCategorizationTest < ActiveSupport::TestCase

  should 'have profile and category' do
    person = create_user('test_user').person
    cat = Environment.default.categories.build(:name => 'a category'); cat.save!
    person.add_category cat
    person.save!
    assert_includes person.categories, cat
    assert_includes cat.people, person
    assert_equal [cat.id], person.category_ids
  end

  should 'create instances for the entire hierarchy' do
    c1 = Environment.default.categories.create!(:name => 'c1')
    c2 = Environment.default.categories.create!(:name => 'c2').tap do |c|
      c.parent_id = c1.id
    end

    p = create_user('testuser').person

    assert_difference 'ProfileCategorization.count(:category_id)', 2 do
      ProfileCategorization.add_category_to_profile(c2, p)
    end

    assert_equal 2, ProfileCategorization.where(profile_id: p.id).count
  end

  should 'not duplicate entry for category that is parent of two others' do
    c1 = Environment.default.categories.create!(:name => 'c1')
    c2 = Environment.default.categories.create!(:name => 'c2').tap do |c|
      c.parent_id = c1.id
    end
    c3 = Environment.default.categories.create!(:name => 'c3').tap do |c|
      c.parent_id = c1.id
    end

    p = create_user('testuser').person

    assert_difference 'ProfileCategorization.count(:category_id)', 3 do
      ProfileCategorization.add_category_to_profile(c2, p)
      ProfileCategorization.add_category_to_profile(c3, p)
    end
  end

  should 'remove all instances for a given profile' do
    c1 = Environment.default.categories.create!(:name => 'c1')
    c2 = Environment.default.categories.create!(:name => 'c2').tap do |c|
      c.parent_id = c1.id
    end
    c3 = Environment.default.categories.create!(:name => 'c3').tap do |c|
      c.parent_id = c1.id
    end

    p = create_user('testuser').person

    ProfileCategorization.add_category_to_profile(c2, p)
    ProfileCategorization.add_category_to_profile(c3, p)

    assert_difference 'ProfileCategorization.count(:category_id)', -3 do
      ProfileCategorization.remove_all_for(p)
    end
  end

  [ Region, State, City ].each do |klass|
    should "be able to remove #{klass.name} from profile" do
      region = Environment.default.send(klass.name.underscore.pluralize).create!(:name => 'my region')
      p = create_user('testuser').person
      p.region = region
      p.save!

      ProfileCategorization.remove_region(p)

      assert_equal [], p.categories(true)
    end
  end

end
