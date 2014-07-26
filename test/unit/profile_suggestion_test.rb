# encoding: UTF-8
require File.dirname(__FILE__) + '/../test_helper'

class ProfileSuggestionTest < ActiveSupport::TestCase

  should 'save the profile class' do
    person = create_user('person').person
    suggested_community = fast_create(Community)

    suggestion = ProfileSuggestion.create(:person => person, :suggestion => suggested_community)
    assert_equal 'Community', suggestion.suggestion_type
  end

  should 'only accept pre-defined categories' do
    person = create_user('person').person
    suggested_community = fast_create(Community)

    suggestion = ProfileSuggestion.new(:person => person, :suggestion => suggested_community)

    suggestion.categories = {:unexistent => 1}
    suggestion.valid?
    assert suggestion.errors[:categories.to_s].present?
  end

  should 'disable a suggestion' do
    person = create_user('person').person
    suggested_community = fast_create(Community)

    suggestion = ProfileSuggestion.create(:person => person, :suggestion => suggested_community)

    suggestion.disable
    assert_equal false, ProfileSuggestion.find(suggestion.id).enabled?
  end

  should 'not suggest the same community twice' do
    person = create_user('person').person
    suggested_community = fast_create(Community)

    ProfileSuggestion.create(:person => person, :suggestion => suggested_community)

    repeated_suggestion = ProfileSuggestion.new(:person => person, :suggestion => suggested_community)

    repeated_suggestion.valid?
    assert_equal true, repeated_suggestion.errors[:suggestion_id.to_s].present?
  end

end
