# encoding: UTF-8
require File.dirname(__FILE__) + '/../test_helper'

class ProfileSuggestionTest < ActiveSupport::TestCase

  def setup
    @person = create_user('test_user').person
    @community = fast_create(Community)
  end
  attr_reader :person, :community

  should 'save the profile class' do
    suggestion = ProfileSuggestion.create(:person => person, :suggestion => community)
    assert_equal 'Community', suggestion.suggestion_type
  end

  should 'only accept pre-defined categories' do
    suggestion = ProfileSuggestion.new(:person => person, :suggestion => community)

    suggestion.categories = {:unexistent => 1}
    suggestion.valid?
    assert suggestion.errors[:categories.to_s].present?
  end

  should 'disable a suggestion' do
    suggestion = ProfileSuggestion.create(:person => person, :suggestion => community)

    suggestion.disable
    assert_equal false, ProfileSuggestion.find(suggestion.id).enabled?
  end

  should 'not suggest the same community twice' do
    ProfileSuggestion.create(:person => person, :suggestion => community)

    repeated_suggestion = ProfileSuggestion.new(:person => person, :suggestion => community)

    repeated_suggestion.valid?
    assert_equal true, repeated_suggestion.errors[:suggestion_id.to_s].present?
  end

  should 'update existing person suggestion when the number of common friends increase' do
    suggested_person = create_user('test_user').person
    suggestion = ProfileSuggestion.create(:person => person, :suggestion => suggested_person, :common_friends => 2)

    friend = create_user('friend').person
    friend2 = create_user('friend2').person
    friend3 = create_user('friend2').person
    person.add_friend friend
    person.add_friend friend2
    person.add_friend friend3

    friend.add_friend suggested_person

    suggested_person.add_friend friend
    suggested_person.add_friend friend2
    suggested_person.add_friend friend3

    assert_difference 'ProfileSuggestion.find(suggestion.id).common_friends', 1 do
      ProfileSuggestion.friends_of_friends(person)
   end
  end

  should 'update existing person suggestion when the number of common communities increase' do
    suggested_person = create_user('test_user').person
    suggestion = ProfileSuggestion.create(:person => person, :suggestion => suggested_person, :common_communities => 1)

    community.add_member person
    community.add_member suggested_person

    community2 = fast_create(Community)
    community2.add_member person
    community2.add_member suggested_person

    assert_difference 'ProfileSuggestion.find(suggestion.id).common_communities', 1 do
      ProfileSuggestion.people_with_common_communities(person)
    end
  end

  should 'update existing person suggestion when the number of common tags increase' do
    suggested_person = create_user('test_user').person
    suggestion = ProfileSuggestion.create(:person => person, :suggestion => suggested_person, :common_tags => 1)

    create(Article, :created_by => person, :profile => person, :tag_list => 'first-tag, second-tag, third-tag, fourth-tag')
    create(Article, :created_by => suggested_person, :profile => suggested_person, :tag_list => 'first-tag, second-tag, third-tag')

    assert_difference 'ProfileSuggestion.find(suggestion.id).common_tags', 2 do
      ProfileSuggestion.people_with_common_tags(person)
    end
  end

  should 'update existing community suggestion when the number of common friends increase' do
    suggestion = ProfileSuggestion.create(:person => person, :suggestion => community, :common_friends => 1)

    member1 = create_user('member1').person
    member2 = create_user('member2').person

    person.add_friend member1
    person.add_friend member2

    community.add_member member1
    community.add_member member2

    assert_difference 'ProfileSuggestion.find(suggestion.id).common_friends', 1 do
      ProfileSuggestion.communities_with_common_friends(person)
    end

  end

  should 'update existing community suggestion when the number of common tags increase' do
    other_person = create_user('test_user').person

    suggestion = ProfileSuggestion.create(:person => person, :suggestion => community, :common_tags => 1)

    create(Article, :created_by => person, :profile => person, :tag_list => 'first-tag, second-tag, third-tag, fourth-tag')
    create(Article, :created_by => other_person, :profile => community, :tag_list => 'first-tag, second-tag, third-tag')

    assert_difference 'ProfileSuggestion.find(suggestion.id).common_tags', 2 do
      ProfileSuggestion.communities_with_common_tags(person)
    end
  end
end
