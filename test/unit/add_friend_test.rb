require_relative "../test_helper"

class AddFriendTest < ActiveSupport::TestCase

  def setup
    @person1 = create_user('testuser1').person
    @person2 = create_user('testuser2').person
  end
  attr_reader :person1, :person2

  should 'be a task' do
    ok { AddFriend.new.kind_of?(Task) }
  end

  should 'actually create friendships (two way) when confirmed' do

    task = fast_create(AddFriend, :requestor_id => person1.id, :target_id => person2.id, :target_type => 'Person')

    assert_difference 'Friendship.count', 2 do
      task.finish
    end
    person1.friends.reload
    person2.friends.reload

    ok('person1 should have person2 as friend') { person1.friends.include?(person2) }
    ok('person2 should have person1 as friend') { person2.friends.include?(person1) }
  end

  should 'put friendships in the right groups' do
    task = fast_create(AddFriend, :requestor_id => person1, :target_id => person2.id, :target_type => 'Person')
    task.group_for_person = 'friend1'
    task.group_for_friend = 'friend2'
    assert task.save

    assert_difference 'Friendship.count', 2 do
      task.finish
    end

    ok('person1 should list person2 as friend1') { person1.friendships.first.group == 'friend1' }
    ok('person2 should have person1 as friend2') { person2.friendships.first.group == 'friend2' }
  end

  should 'require requestor (person adding other as friend)' do
    task = AddFriend.new
    task.valid?

    ok('must not validate with empty requestor') { task.errors[:requestor_id.to_s].present? }

    task.requestor = Person.new
    task.valid?
    ok('must validate when requestor is given') { task.errors[:requestor_id.to_s].present?}

  end

  should 'require target (person being added)' do
    task = AddFriend.new
    task.valid?

    ok('must not validate with empty target') { task.errors[:target_id.to_s].present? }

    task.target = Person.new
    task.valid?
    ok('must validate when target is given') { task.errors[:target_id.to_s].present?}
  end

  should 'send e-mails' do
    mailer = mock
    mailer.expects(:deliver).at_least_once
    TaskMailer.expects(:target_notification).returns(mailer).at_least_once

    task = AddFriend.create!(:person => person1, :friend => person2)
  end

  should 'has permission to manage friends' do
    t = AddFriend.new
    assert_equal :manage_friends, t.permission
  end

  should 'not add friend twice' do
    create AddFriend, person: person1, friend: person2, status: 1
    assert_raise ActiveRecord::RecordInvalid do
      create AddFriend, person: person1, friend: person2, status: 1
    end
  end

  should 'override target notification message method from Task' do
    task = AddFriend.new(:person => person1, :friend => person2)
    assert_nothing_raised NotImplementedError do
      task.target_notification_message
    end
  end

  should 'limit "group for person" number of characters' do
    #Max value is 150
    big_word = 'a' * 155
    task = AddFriend.new

    task.group_for_person = big_word
    task.valid?
    assert task.errors[:group_for_person].present?

    task.group_for_person = 'short name'
    task.valid?
    assert !task.errors[:group_for_person].present?
  end

  should 'limit "group for friend" number of characters' do
    #Max value is 150
    big_word = 'a' * 155
    task = AddFriend.new

    task.group_for_friend = big_word
    task.valid?
    assert task.errors[:group_for_friend].present?

    task.group_for_friend = 'short name'
    task.valid?
    assert !task.errors[:group_for_friend].present?
  end

  should 'have target notification message if is organization and not moderated' do
    task = AddFriend.new(:person => person1, :friend => person2)

    assert_match(/wants to be your friend.*[\n]*.*to accept/, task.target_notification_message)
  end

  should 'have target notification description' do
    task = AddFriend.new(:person => person1, :friend => person2)

    assert_match(/#{task.requestor.name} wants to be your friend/, task.target_notification_description)
  end

  should 'deliver target notification message' do
    task = AddFriend.new(:person => person1, :friend => person2)

    email = TaskMailer.target_notification(task, task.target_notification_message).deliver
    assert_match(/#{task.requestor.name} wants to be your friend/, email.subject)
  end

  should 'disable suggestion if profile requested friendship' do
    suggestion = ProfileSuggestion.create(:person => person1, :suggestion => person2, :enabled => true)

    task = AddFriend.create(:person => person1, :friend => person2)
    assert_equal false, ProfileSuggestion.find(suggestion.id).enabled
  end

end
