require_relative 'test_helper'

class ActivitiesTest < ActiveSupport::TestCase

  def setup
    create_and_activate_user
    login_api
  end

  should 'get own activities' do
    create_activity(person)

    get "/api/v1/profiles/#{person.id}/activities?#{params.to_query}"
    json = JSON.parse(last_response.body)

    assert 1, json["activities"].count
    assert_equivalent person.activities.map(&:activity).map(&:id), json["activities"].map{|c| c["id"]}
  end

  should 'not get private community activities' do
    community = fast_create(Community, :public_profile => false)
    create_activity(community)

    get "/api/v1/profiles/#{community.id}/activities?#{params.to_query}"
    json = JSON.parse(last_response.body)
    assert_nil json["activities"]
    assert_equal 403, last_response.status
  end

  should 'not get community activities if not member' do
    community = fast_create(Community)
    other_person = fast_create(Person)
    community.add_member(other_person) # so there is an activity in community

    get "/api/v1/profiles/#{community.id}/activities?#{params.to_query}"
    json = JSON.parse(last_response.body)
    assert_nil json["activities"]
    assert_equal 403, last_response.status
  end

  should 'get community activities for member' do
    community = fast_create(Community)
    create_activity(community)
    community.add_member(person)

    get "/api/v1/profiles/#{community.id}/activities?#{params.to_query}"
    json = JSON.parse(last_response.body)
    assert_equivalent community.activities.map(&:activity).map(&:id), json["activities"].map{|c| c["id"]}
  end

  should 'not get other person activities' do
    other_person = fast_create(Person)
    create_activity(other_person)

    get "/api/v1/profiles/#{other_person.id}/activities?#{params.to_query}"
    json = JSON.parse(last_response.body)
    assert_nil json["activities"]
    assert_equal 403, last_response.status
  end

  should 'get friend activities' do
    other_person = fast_create(Person)
    other_person.add_friend(person)
    create_activity(other_person)

    get "/api/v1/profiles/#{other_person.id}/activities?#{params.to_query}"
    json = JSON.parse(last_response.body)
    assert_equivalent other_person.activities.map(&:activity).map(&:id), json["activities"].map{|c| c["id"]}
  end

  def create_activity(target)
    activity = ActionTracker::Record.create! :verb => :leave_scrap, :user => person, :target => target
    ProfileActivity.create! profile_id: target.id, activity: activity
  end

end
