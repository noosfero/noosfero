class Friendship < ApplicationRecord

  track_actions :new_friendship, :after_create, :keep_params => ["friend.name", "friend.url", "friend.profile_custom_icon"], :custom_user => :person

  extend CacheCounter

  belongs_to :person, :foreign_key => :person_id
  belongs_to :friend, :class_name => 'Person', :foreign_key => 'friend_id'

  after_create do |friendship|
    Friendship.update_cache_counter(:friends_count, friendship.person, 1)
    Friendship.update_cache_counter(:friends_count, friendship.friend, 1)

    circles = friendship.group.blank? ? ['friendships'] : friendship.group.split(',').map(&:strip)
    circles.each do |circle|
      friendship.person.follow(friendship.friend, Circle.find_or_create_by(:person => friendship.person, :name => circle, :profile_type => 'Person'))
    end
  end

  after_destroy do |friendship|
    Friendship.update_cache_counter(:friends_count, friendship.person, -1)
    Friendship.update_cache_counter(:friends_count, friendship.friend, -1)

    groups = friendship.group.blank? ? ['friendships'] : friendship.group.split(',').map(&:strip)
    groups.each do |group|
      circle = Circle.find_by(:person => friendship.person, :name => group )
      friendship.person.remove_profile_from_circle(friendship.friend, circle) if circle
    end
  end

  def self.remove_friendship(person1, person2)
    person1.remove_friend(person2)
    person2.remove_friend(person1)
  end
end
