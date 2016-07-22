require_relative "../test_helper"

class ProfileFollowersTest < ActiveSupport::TestCase

  should 'a person follow another' do
    p1 = create_user('person_test').person
    p2 = create_user('person_test_2').person
    circle = Circle.create!(:person=> p1, :name => "Zombies", :profile_type => 'Person')

    assert_difference 'ProfileFollower.count' do
      p1.follow(p2, circle)
    end

    assert_includes p2.followers(true), p1
    assert_not_includes p1.followers(true), p2
  end

  should 'a person unfollow another person' do
    p1 = create_user('person_test').person
    p2 = create_user('person_test_2').person
    circle = Circle.create!(:person=> p1, :name => "Zombies", :profile_type => 'Person')

    p1.follow(p2,circle)

    assert_difference 'ProfileFollower.count', -1 do
      p1.unfollow(p2)
    end

    assert_not_includes p2.followers(true), p1
  end

  should 'get the followed persons for a profile' do
    p1 = create_user('person_test').person
    p2 = create_user('person_test_2').person
    p3 = create_user('person_test_3').person
    circle = Circle.create!(:person=> p1, :name => "Zombies", :profile_type => 'Person')

    p1.follow(p2, circle)
    p1.follow(p3, circle)

    assert_equivalent p1.followed_profiles, [p2,p3]
    assert_equivalent Profile.followed_by(p1), [p2,p3]
  end

  should 'not follow same person twice' do
    p1 = create_user('person_test').person
    p2 = create_user('person_test_2').person
    circle = Circle.create!(:person=> p1, :name => "Zombies", :profile_type => 'Person')

    assert_difference 'ProfileFollower.count' do
      p1.follow(p2, circle)
      p1.follow(p2, circle)
    end

    assert_equivalent p1.followed_profiles, [p2]
    assert_equivalent p2.followers, [p1]
  end

  should 'show the correct message when a profile is followed by the same person' do
    p1 = create_user('person_test').person
    p2 = create_user('person_test_2').person
    circle = Circle.create!(:person=> p1, :name => "Zombies", :profile_type => 'Person')

    p1.follow(p2, circle)
    profile_follower = ProfileFollower.new
    profile_follower.circle = circle
    profile_follower.profile = p2
    profile_follower.valid?

    assert_includes profile_follower.errors.messages[:profile_id],
      "can't put a profile in the same circle twice"
  end
end
