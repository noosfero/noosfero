require File.dirname(__FILE__) + '/../test_helper'

class FriendshipTest < Test::Unit::TestCase

  should 'connect a person to another' do
    p1 = Person.new(:environment => Environment.default)
    p2 = Person.new(:environment => Environment.default)

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
