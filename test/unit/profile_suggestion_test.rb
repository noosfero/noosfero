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

    suggestions = ProfileSuggestion.calculate_suggestions(p1)

    assert_includes suggestions, p5
    assert_includes suggestions, p6
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

    suggestions = ProfileSuggestion.calculate_suggestions(p1)

    assert_includes suggestions, p2
    assert_includes suggestions, p4
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

    suggestions = ProfileSuggestion.calculate_suggestions(p1)

    assert_includes suggestions, p2
    assert_includes suggestions, p3
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
    p5 = create_user('testuser5').person

    p1.add_friend(p2)
    p1.add_friend(p3)
    p1.add_friend(p4)

    c1.add_member(p2)
    c1.add_member(p3)
    c2.add_member(p2)
    c2.add_member(p4)
    c3.add_member(p2)
    c4.add_member(p3)

    suggestions = ProfileSuggestion.calculate_suggestions(p1)

    assert_includes suggestions, c1
    assert_includes suggestions, c2
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

    suggestions = ProfileSuggestion.calculate_suggestions(p1)

    assert_includes suggestions, p2
    assert_includes suggestions, p3
  end

  should 'calculate new suggestions when number of available suggestions reaches the min_limit' do
    person = create_user('person').person
    (ProfileSuggestion::MIN_LIMIT + 1).times do
      ProfileSuggestion.create!(:person => person, :suggestion => fast_create(Profile))
    end

    ProfileSuggestion.expects(:calculate_suggestions)

    person.suggested_profiles.enabled.last.disable
    person.suggested_profiles.enabled.last.destroy
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
