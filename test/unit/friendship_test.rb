require File.dirname(__FILE__) + '/../test_helper'

class FriendshipTest < Test::Unit::TestCase

  should 'connect a person to another' do
    p1 = create_user('person_test').person
    p2 = create_user('person_test_2').person

    f = Friendship.new
    assert_raise ActiveRecord::AssociationTypeMismatch do
      f.person = Organization.new
    end
    assert_raise ActiveRecord::AssociationTypeMismatch do
      f.friend = Organization.new
    end
    assert_nothing_raised do
      f.person = p1
      f.friend = p2
    end

    f.save!

  end

end
