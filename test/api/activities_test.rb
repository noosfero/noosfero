require_relative "test_helper"

class ActivitiesTest < ActiveSupport::TestCase
  def setup
    create_and_activate_user
    login_api
  end

  should "get own activities" do
    create_activity(target: person)

    get "/api/v1/profiles/#{person.id}/activities?#{params.to_query}"
    json = JSON.parse(last_response.body)

    assert 1, json.count
    assert_equivalent person.activities.map(&:activity).map(&:id), json.map { |c| c["id"] }
  end

  should "get network activities" do
    fast_create(ActionTrackerNotification, profile_id: person.id, action_tracker_id: fast_create(ActionTracker::Record, user_id: user.id))

    get "/api/v1/profiles/#{person.id}/network_activities?#{params.to_query}"
    json = JSON.parse(last_response.body)
    assert 1, json.count
    assert_equivalent person.tracked_notifications.map(&:id), json.map { |c| c["id"] }
  end

  should "not get private community activities" do
    community = fast_create(Community, access: Entitlement::Levels.levels[:self])
    create_activity(target: community)

    get "/api/v1/profiles/#{community.id}/activities?#{params.to_query}"
    json = JSON.parse(last_response.body)
    assert_not_nil json["message"]
    assert_equal 403, last_response.status
  end

  should "not get community activities if not member and community is private" do
    community = fast_create(Community, access: Entitlement::Levels.levels[:self])
    other_person = fast_create(Person)
    community.add_member(other_person) # so there is an activity in community

    get "/api/v1/profiles/#{community.id}/activities?#{params.to_query}"
    json = JSON.parse(last_response.body)
    assert_not_nil json["message"]
    assert_equal 403, last_response.status
  end

  should "get community activities for member" do
    community = fast_create(Community)
    create_activity(target: community)
    community.add_member(person)

    get "/api/v1/profiles/#{community.id}/activities?#{params.to_query}"
    json = JSON.parse(last_response.body)
    assert_equivalent community.activities.map(&:activity).map(&:id), json.map { |c| c["id"] }
  end

  should "not get other person activities" do
    other_person = fast_create(Person)
    create_activity(target: other_person)

    get "/api/v1/profiles/#{other_person.id}/activities?#{params.to_query}"
    json = JSON.parse(last_response.body)
    assert_not_nil json["message"]
    assert_equal 403, last_response.status
  end

  should "get friend activities" do
    other_person = fast_create(Person)
    other_person.add_friend(person)
    create_activity(target: other_person)

    get "/api/v1/profiles/#{other_person.id}/activities?#{params.to_query}"
    json = JSON.parse(last_response.body)
    assert_equivalent other_person.activities.map(&:activity).map(&:id), json.map { |c| c["id"] }
  end

  should "get activities for non logged user in a public community" do
    community = fast_create(Community)
    create_activity(target: community)
    community.add_member(person)
    get "/api/v1/profiles/#{community.id}/activities?#{params.to_query}"
    json = JSON.parse(last_response.body)
    assert_equivalent community.activities.map(&:activity).map(&:id), json.map { |c| c["id"] }
  end

  should "not crash api if an scrap activity is in the list" do
    create_activity(target: person)
    create(Scrap, sender_id: person.id, receiver_id: person.id)

    assert_nothing_raised do
      get "/api/v1/profiles/#{person.id}/activities?#{params.to_query}"
    end
  end

  should "scrap activity be returned in acitivities list" do
    create_activity(target: person)
    create(Scrap, sender_id: person.id, receiver_id: person.id)

    get "/api/v1/profiles/#{person.id}/activities?#{params.to_query}"
    json = JSON.parse(last_response.body)

    assert_equivalent person.activities.map(&:activity).map(&:id), json.map { |c| c["id"] }
  end

  should "always return the activity verb parameter" do
    ActionTracker::Record.destroy_all
    ProfileActivity.destroy_all
    create_activity(target: person)
    get "/api/v1/profiles/#{person.id}/activities?#{params.to_query}"
    json = JSON.parse(last_response.body)
    assert_equal "create_article", json.last["verb"]
  end

  should "scrap activity return leave_scrap verb" do
    ActionTracker::Record.destroy_all
    create(TextArticle, name: "Tracked Article 1", profile_id: person.id)
    create(Scrap, sender_id: person.id, receiver_id: person.id)
    get "/api/v1/profiles/#{person.id}/activities?#{params.to_query}"
    json = JSON.parse(last_response.body)
    assert_equivalent ["create_article", "leave_scrap"], json.map { |a| a["verb"] }
  end

  should "the content be returned in scrap activities" do
    ActionTracker::Record.destroy_all
    content = "some content"
    create(Scrap, sender_id: person.id, receiver_id: person.id, content: content)
    get "/api/v1/profiles/#{person.id}/activities?#{params.to_query}"
    json = JSON.parse(last_response.body)
    assert_equal content, json.last["content"]
  end

  should "not return the content in other kind of activities except scrap" do
    ActionTracker::Record.destroy_all
    create_activity(target: person)
    get "/api/v1/profiles/#{person.id}/activities?#{params.to_query}"
    json = JSON.parse(last_response.body)
    assert_nil json.last["content"]
  end

  should "list activities with pagination" do
    ActionTracker::Record.destroy_all
    a1 = create_activity(target: person)
    a2 = create_activity(target: person)

    params[:page] = 1
    params[:per_page] = 1
    get "/api/v1/profiles/#{person.id}/activities?#{params.to_query}"
    json_page_one = JSON.parse(last_response.body)

    params[:page] = 2
    params[:per_page] = 1
    get "/api/v1/profiles/#{person.id}/activities?#{params.to_query}"
    json_page_two = JSON.parse(last_response.body)

    assert_includes json_page_one.map { |a| a["id"] }, a2.id
    assert_not_includes json_page_one.map { |a| a["id"] }, a1.id

    assert_includes json_page_two.map { |a| a["id"] }, a1.id
    assert_not_includes json_page_two.map { |a| a["id"] }, a2.id
  end

  should "list only 20 elements by page if no limit param is passed" do
    ActionTracker::Record.destroy_all
    1.upto(25).map do
      create_activity(target: person)
    end
    get "/api/v1/profiles/#{person.id}/activities?#{params.to_query}"
    json = JSON.parse(last_response.body)
    assert_equal 20, json.length
  end

  should "list activities with timestamp" do
    ActionTracker::Record.destroy_all
    a1 = create_activity(target: person)
    a2 = create_activity(target: person)
    a2.updated_at = Time.now.in_time_zone
    a2.save

    a1.updated_at = Time.now.in_time_zone + 3.hours
    a1.save!

    params[:timestamp] = Time.now.in_time_zone + 1.hours
    get "/api/v1/profiles/#{person.id}/activities?#{params.to_query}"
    json = JSON.parse(last_response.body)

    assert_includes json.map { |a| a["id"] }, a1.id
    assert_not_includes json.map { |a| a["id"] }, a2.id
  end

  should "list activities with timestamp considering timezone" do
    ActionTracker::Record.destroy_all
    a1 = create_activity(target: person)
    a2 = create_activity(target: person)
    a2.updated_at = ActiveSupport::TimeZone.new("Brasilia").now
    a2.save

    a1.updated_at = ActiveSupport::TimeZone.new("Brasilia").now + 3.hours
    a1.save!

    params[:timestamp] = ActiveSupport::TimeZone.new("Brasilia").now + 1.hours
    get "/api/v1/profiles/#{person.id}/activities?#{params.to_query}"
    json = JSON.parse(last_response.body)

    assert_includes json.map { |a| a["id"] }, a1.id
    assert_not_includes json.map { |a| a["id"] }, a2.id
  end

  def create_activity(params = {})
    params[:verb] ||= "create_article"
    ActionTracker::Record.create!(params.merge(user: person))
  end
end
