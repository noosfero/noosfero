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

end
