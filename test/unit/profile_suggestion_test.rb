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

  should 'calculate people with common friends' do
    p1 = create_user('testuser1').person
    p2 = create_user('testuser2').person
    p3 = create_user('testuser3').person
    p4 = create_user('testuser4').person
    p5 = create_user('testuser4').person
    p6 = create_user('testuser4').person
    p7 = create_user('testuser4').person

    p1.add_friend(p2) ; p2.add_friend(p1)
    p1.add_friend(p3) ; p3.add_friend(p1)
    p1.add_friend(p4) ; p2.add_friend(p3)
    p3.add_friend(p2) ; p4.add_friend(p1)
    p2.add_friend(p5) ; p5.add_friend(p2)
    p2.add_friend(p6) ; p6.add_friend(p2)
    p3.add_friend(p5) ; p5.add_friend(p3)
    p4.add_friend(p6) ; p6.add_friend(p4)
    p2.add_friend(p7) ; p7.add_friend(p2)

    assert_equivalent ProfileSuggestion.people_with_common_friends(p1), [p5,p6]
  end

  should 'calculate people with common_communities' do
    c1 = fast_create(Community)
    c2 = fast_create(Community)
    c3 = fast_create(Community)
    c4 = fast_create(Community)
    p1 = create_user('testuser1').person
    p2 = create_user('testuser2').person
    p3 = create_user('testuser3').person
    p4 = create_user('testuser4').person
    p5 = create_user('testuser4').person

    c1.add_member(p1)
    c1.add_member(p2)
    c1.add_member(p3)
    c2.add_member(p1)
    c2.add_member(p2)
    c2.add_member(p4)
    c3.add_member(p1)
    c3.add_member(p4)
    c4.add_member(p5)

    assert_equivalent ProfileSuggestion.people_with_common_communities(p1), [p2,p4]
  end

  should 'calculate people with common_tags' do
    p1 = create_user('testuser1').person
    a11 = fast_create(Article, :profile_id => p1.id)
    a11.tag_list = ['free software', 'veganism']
    a11.save!
    a12 = fast_create(Article, :profile_id => p1.id)
    a12.tag_list = ['anarchism']
    a12.save!
    p2 = create_user('testuser2').person
    a21 = fast_create(Article, :profile_id => p2.id)
    a21.tag_list = ['free software']
    a21.save!
    a22 = fast_create(Article, :profile_id => p2.id)
    a22.tag_list = ['veganism']
    a22.save!
    p3 = create_user('testuser3').person
    a31 = fast_create(Article, :profile_id => p3.id)
    a31.tag_list = ['anarchism']
    a31.save!
    a32 = fast_create(Article, :profile_id => p3.id)
    a32.tag_list = ['veganism']
    a32.save!
    p4 = create_user('testuser4').person
    a41 = fast_create(Article, :profile_id => p4.id)
    a41.tag_list = ['free software', 'marxism']
    a41.save!
    a42 = fast_create(Article, :profile_id => p4.id)
    a42.tag_list = ['free software', 'vegetarianism',]
    a42.save!
    p5 = create_user('testuser4').person
    a51 = fast_create(Article, :profile_id => p5.id)
    a51.tag_list = ['proprietary software']
    a51.save!
    a52 = fast_create(Article, :profile_id => p5.id)
    a52.tag_list = ['onivorism', 'facism']
    a52.save!

    assert_equivalent ProfileSuggestion.people_with_common_tags(p1), [p2, p3]
  end

  should 'calculate communities with common_friends' do
    c1 = fast_create(Community)
    c2 = fast_create(Community)
    c3 = fast_create(Community)
    c4 = fast_create(Community)
    p1 = create_user('testuser1').person
    p2 = create_user('testuser2').person
    p3 = create_user('testuser3').person
    p4 = create_user('testuser4').person
    p5 = create_user('testuser4').person

    p1.add_friend(p2)
    p1.add_friend(p3)
    p1.add_friend(p4)

    c1.add_member(p2)
    c1.add_member(p3)
    c2.add_member(p2)
    c2.add_member(p4)
    c3.add_member(p2)
    c4.add_member(p3)

    assert_equivalent ProfileSuggestion.communities_with_common_friends(p1), [c1,c2]
  end

  should 'calculate communities with common_tags' do
    p1 = create_user('testuser1').person
    a11 = fast_create(Article, :profile_id => p1.id)
    a11.tag_list = ['free software', 'veganism']
    a11.save!
    a12 = fast_create(Article, :profile_id => p1.id)
    a12.tag_list = ['anarchism']
    a12.save!
    p2 = fast_create(Community)
    a21 = fast_create(Article, :profile_id => p2.id)
    a21.tag_list = ['free software']
    a21.save!
    a22 = fast_create(Article, :profile_id => p2.id)
    a22.tag_list = ['veganism']
    a22.save!
    p3 = fast_create(Community)
    a31 = fast_create(Article, :profile_id => p3.id)
    a31.tag_list = ['anarchism']
    a31.save!
    a32 = fast_create(Article, :profile_id => p3.id)
    a32.tag_list = ['veganism']
    a32.save!
    p4 = fast_create(Community)
    a41 = fast_create(Article, :profile_id => p4.id)
    a41.tag_list = ['free software', 'marxism']
    a41.save!
    a42 = fast_create(Article, :profile_id => p4.id)
    a42.tag_list = ['free software', 'vegetarianism',]
    a42.save!
    p5 = fast_create(Community)
    a51 = fast_create(Article, :profile_id => p5.id)
    a51.tag_list = ['proprietary software']
    a51.save!
    a52 = fast_create(Article, :profile_id => p5.id)
    a52.tag_list = ['onivorism', 'facism']
    a52.save!

    assert_equivalent ProfileSuggestion.communities_with_common_tags(p1), [p2, p3]
  end

  should 'register suggestions' do
    person = create_user('person').person
    rule = ProfileSuggestion::RULES.sample
    p1 = fast_create(Profile)
    p2 = fast_create(Profile)
    p3 = fast_create(Profile)
    # Hack to simulate a common_count that generated on the rules
    suggestions = Profile.select('profiles.*, profiles.id as common_count').where("id in (#{[p1,p2,p3].map(&:id).join(',')})")

    assert_difference 'ProfileSuggestion.count', 3 do
      ProfileSuggestion.register_suggestions(person, suggestions, rule)
    end
    assert_no_difference 'ProfileSuggestion.count' do
      s1 = ProfileSuggestion.find_or_initialize_by_suggestion_id(p1.id)
      assert_equal p1, s1.suggestion
      s2 = ProfileSuggestion.find_or_initialize_by_suggestion_id(p2.id)
      assert_equal p2, s2.suggestion
      s3 = ProfileSuggestion.find_or_initialize_by_suggestion_id(p3.id)
      assert_equal p3, s3.suggestion
    end
  end

  should 'calculate every rule suggestion' do
    person = create_user('person').person
    ProfileSuggestion::RULES.each do |rule|
      suggestion = fast_create(Profile)
      ProfileSuggestion.expects(rule).returns([suggestion])
      ProfileSuggestion.expects(:register_suggestions).with(person, [suggestion], rule).returns(true)
    end
    ProfileSuggestion.calculate_suggestions(person)
  end

#FIXME This might not be necessary anymore...
#  should 'update existing person suggestion when the number of common friends increase' do
#    suggested_person = create_user('test_user').person
#    suggestion = ProfileSuggestion.create(:person => person, :suggestion => suggested_person, :common_friends => 2)
#
#    friend = create_user('friend').person
#    friend2 = create_user('friend2').person
#    friend3 = create_user('friend2').person
#    person.add_friend friend
#    person.add_friend friend2
#    person.add_friend friend3
#
#    friend.add_friend suggested_person
#
#    suggested_person.add_friend friend
#    suggested_person.add_friend friend2
#    suggested_person.add_friend friend3
#
#    assert_difference 'ProfileSuggestion.find(suggestion.id).common_friends', 1 do
#      ProfileSuggestion.register_suggestions(person, ProfileSuggestion.people_with_common_friends(person), 'people_with_common_friends')
#    end
#  end
#
#  should 'update existing person suggestion when the number of common communities increase' do
#    suggested_person = create_user('test_user').person
#    suggestion = ProfileSuggestion.create(:person => person, :suggestion => suggested_person, :common_communities => 1)
#
#    community.add_member person
#    community.add_member suggested_person
#
#    community2 = fast_create(Community)
#    community2.add_member person
#    community2.add_member suggested_person
#
#    assert_difference 'ProfileSuggestion.find(suggestion.id).common_communities', 1 do
#      ProfileSuggestion.register_suggestions(person, ProfileSuggestion.people_with_common_communities(person), 'people_with_common_communities')
#    end
#  end
#
#  should 'update existing person suggestion when the number of common tags increase' do
#    suggested_person = create_user('test_user').person
#    suggestion = ProfileSuggestion.create(:person => person, :suggestion => suggested_person, :common_tags => 1)
#
#    create(Article, :created_by => person, :profile => person, :tag_list => 'first-tag, second-tag, third-tag, fourth-tag')
#    create(Article, :created_by => suggested_person, :profile => suggested_person, :tag_list => 'first-tag, second-tag, third-tag')
#
#    assert_difference 'ProfileSuggestion.find(suggestion.id).common_tags', 2 do
#      ProfileSuggestion.register_suggestions(person, ProfileSuggestion.people_with_common_tags(person), 'people_with_common_tags')
#    end
#  end
#
#  should 'update existing community suggestion when the number of common friends increase' do
#    suggestion = ProfileSuggestion.create(:person => person, :suggestion => community, :common_friends => 1)
#
#    member1 = create_user('member1').person
#    member2 = create_user('member2').person
#
#    person.add_friend member1
#    person.add_friend member2
#
#    community.add_member member1
#    community.add_member member2
#
#    assert_difference 'ProfileSuggestion.find(suggestion.id).common_friends', 1 do
#      ProfileSuggestion.register_suggestions(person, ProfileSuggestion.communities_with_common_friends(person), 'communities_with_common_friends')
#    end
#
#  end
#
#  should 'update existing community suggestion when the number of common tags increase' do
#    other_person = create_user('test_user').person
#
#    suggestion = ProfileSuggestion.create(:person => person, :suggestion => community, :common_tags => 1)
#
#    create(Article, :created_by => person, :profile => person, :tag_list => 'first-tag, second-tag, third-tag, fourth-tag')
#    create(Article, :created_by => other_person, :profile => community, :tag_list => 'first-tag, second-tag, third-tag')
#
#    assert_difference 'ProfileSuggestion.find(suggestion.id).common_tags', 2 do
#      ProfileSuggestion.register_suggestions(person, ProfileSuggestion.communities_with_common_tags(person), 'communities_with_common_tags')
#    end
#  end

  should 'register only new suggestions' do
    person = create_user('person').person
    ProfileSuggestion::SUGGESTIONS_BY_RULE.times do
      ProfileSuggestion.create!(:person => person, :suggestion => fast_create(Person))
    end

    person.reload
    new_suggestion = fast_create(Person)
    ids = (person.suggested_people + [new_suggestion]).map(&:id).join(',')
    suggested_profiles = Profile.select('profiles.*, profiles.id as common_count').where("profiles.id IN (#{ids})")

    assert_difference 'ProfileSuggestion.count', 1 do
      ProfileSuggestion.register_suggestions(person, suggested_profiles, 'people_with_common_friends')
    end
  end

  should 'calculate new suggestions when number of available suggestions reaches the min_limit' do
    person = create_user('person').person
    (ProfileSuggestion::MIN_LIMIT + 1).times do
      ProfileSuggestion.create!(:person => person, :suggestion => fast_create(Profile))
    end

    ProfileSuggestion.expects(:calculate_suggestions)

    person.profile_suggestions.enabled.last.disable
    person.profile_suggestions.enabled.last.destroy
    process_delayed_job_queue
  end

  should 'not create job to calculate new suggestions if there is already enough suggestions enabled' do
    person = create_user('person').person
    (ProfileSuggestion::MIN_LIMIT + 1).times do
      ProfileSuggestion.create!(:person => person, :suggestion => fast_create(Profile))
    end

    ProfileSuggestion.expects(:calculate_suggestions).never
    ProfileSuggestion.generate_profile_suggestions(person)
    process_delayed_job_queue
  end

  should 'be able to force suggestions calculation' do
    person = create_user('person').person
    (ProfileSuggestion::MIN_LIMIT + 1).times do
      ProfileSuggestion.create!(:person => person, :suggestion => fast_create(Profile))
    end

    ProfileSuggestion.expects(:calculate_suggestions)
    ProfileSuggestion.generate_profile_suggestions(person, true)
    process_delayed_job_queue
  end
end
