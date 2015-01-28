require File.dirname(__FILE__) + '/../test_helper'

class ProfileSuggestionsJobTest < ActiveSupport::TestCase

  should 'suggest friends from friends' do
    person = create_user('person').person
    friend = create_user('friend').person
    friend2 = create_user('friend2').person

    person.add_friend friend
    person.add_friend friend2

    friend_of_friend = create_user('friend_of_friend').person
    friend.add_friend friend_of_friend

    friend_of_friend.add_friend friend
    friend_of_friend.add_friend friend2

    job = ProfileSuggestionsJob.new(person.id)
    assert_difference 'ProfileSuggestion.count', 1 do
      job.perform
    end
    assert_equal [friend_of_friend], person.suggested_people
  end

  should 'suggest friends from communities' do
    person = create_user('person').person
    c1 = fast_create(Community)
    c2 = fast_create(Community)

    member1 = create_user('member1').person
    member2 = create_user('member2').person

    c1.add_member person
    c1.add_member member1
    c1.add_member member2
    c2.add_member person
    c2.add_member member1
    c2.add_member member2

    job = ProfileSuggestionsJob.new(person.id)
    assert_difference 'ProfileSuggestion.count', 2 do
      job.perform
    end
    assert_equivalent [member1, member2], person.suggested_people
  end

  should 'suggest friends from tags' do
    person = create_user('person').person
    person2 = create_user('person2').person
    person3 = create_user('person3').person

    create(Article, :created_by => person, :profile => person, :tag_list => 'first-tag, second-tag')
    create(Article, :created_by => person2, :profile => person2, :tag_list => 'first-tag, second-tag, third-tag')
    create(Article, :created_by => person3, :profile => person3, :tag_list => 'first-tag')

    job = ProfileSuggestionsJob.new(person.id)
    assert_difference 'ProfileSuggestion.count', 1 do
      job.perform
    end
    assert_equivalent [person2], person.suggested_people
  end

  should 'suggest from communities friends' do
    person = create_user('person').person

    member1 = create_user('member1').person
    member2 = create_user('member2').person

    person.add_friend member1
    person.add_friend member2

    community = fast_create(Community)
    community.add_member member1
    community.add_member member2

    job = ProfileSuggestionsJob.new(person.id)
    assert_difference 'ProfileSuggestion.count', 1 do
      job.perform
    end
    assert_equivalent [community], person.suggested_communities
  end

  should 'suggest communities from tags' do
    person = create_user('person').person
    person2 = create_user('person2').person

    community = fast_create(Community)
    community.add_admin person2

    create(Article, :created_by => person, :profile => person, :tag_list => 'first-tag, second-tag')
    create(Article, :created_by => person2, :profile => community, :tag_list => 'first-tag, second-tag, third-tag')

    job = ProfileSuggestionsJob.new(person.id)
    assert_difference 'ProfileSuggestion.count', 1 do
      job.perform
    end
    assert_equivalent [community], person.suggested_communities
  end

  should 'send suggestion e-mail only if the user enabled it' do
    person = create_user('person').person
    person.email_suggestions = true
    person.save!
    job = ProfileSuggestionsJob.new(person.id)
    assert_difference 'ActionMailer::Base.deliveries.count', 1  do
      job.perform
    end
  end

  should 'not send suggestion e-mail if the user disabled it' do
    person = create_user('person').person
    person.email_suggestions = false
    person.save!
    job = ProfileSuggestionsJob.new(person.id)
    assert_no_difference 'ActionMailer::Base.deliveries.count'  do
      job.perform
    end
  end

end
