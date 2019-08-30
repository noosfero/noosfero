require_relative "test_helper"

class CommunitiesTest < ActiveSupport::TestCase
  def setup
    Community.delete_all
    create_and_activate_user
  end

  should "list only communities to logged user" do
    login_api
    community = fast_create(Community, environment_id: environment.id)
    enterprise = fast_create(Enterprise, environment_id: environment.id) # should not list this enterprise

    get "/api/v1/communities?#{params.to_query}"
    json = JSON.parse(last_response.body)
    assert_not_includes json.map { |c| c["id"] }, enterprise.id
    assert_includes json.map { |c| c["id"] }, community.id
  end

  should "list all communities to logged user" do
    login_api
    community1 = fast_create(Community, environment_id: environment.id)
    community2 = fast_create(Community, environment_id: environment.id)

    get "/api/v1/communities?#{params.to_query}"
    json = JSON.parse(last_response.body)
    assert_equivalent [community1.id, community2.id], json.map { |c| c["id"] }
  end

  should "not list invisible communities to logged user" do
    login_api
    community1 = fast_create(Community, environment_id: environment.id)
    fast_create(Community, environment_id: environment.id, visible: false)

    get "/api/v1/communities?#{params.to_query}"
    json = JSON.parse(last_response.body)
    assert_equal [community1.id], json.map { |c| c["id"] }
  end

  should "list private communities to logged user" do
    login_api
    community1 = fast_create(Community, environment_id: environment.id)
    community2 = fast_create(Community, environment_id: environment.id,
                                        access: Entitlement::Levels.levels[:users])

    get "/api/v1/communities?#{params.to_query}"
    json = JSON.parse(last_response.body)
    assert_equivalent [community1.id, community2.id], json.map { |c| c["id"] }
  end

  should "list private communities to logged members" do
    login_api
    community1 = fast_create(Community, environment_id: environment.id)
    community2 = fast_create(Community, environment_id: environment.id,
                                        access: Entitlement::Levels.levels[:related])
    community2.add_member(person)

    get "/api/v1/communities?#{params.to_query}"
    json = JSON.parse(last_response.body)
    assert_equivalent [community1.id, community2.id], json.map { |c| c["id"] }
  end

  should "create a community with logged user" do
    login_api
    params[:community] = { name: "some" }
    post "/api/v1/communities?#{params.to_query}"
    json = JSON.parse(last_response.body)
    assert_equal "some", json["name"]
  end

  should "make a create community request if the environment was configured to admin_must_approve_new_communities" do
    login_api
    env = Environment.default
    env.enable("admin_must_approve_new_communities")
    person.stubs(:notification_emails).returns(["sample@example.org"])
    params[:community] = { name: "some" }
    post "/api/v1/communities?#{params.to_query}"
    json = JSON.parse(last_response.body)
    assert_nil json["id"]
  end

  should "not create community with the same identifier" do
    login_api
    community = fast_create(Community)
    params[:community] = { name: community.name }
    post "/api/v1/communities?#{params.to_query}"
    json = JSON.parse(last_response.body)
    assert !json["success"]
    assert_equal Api::Status::ALREADY_EXIST, json["code"]
  end

  should "return 400 status for invalid community creation to logged user " do
    login_api
    post "/api/v1/communities?#{params.to_query}"
    json = JSON.parse(last_response.body)
    assert_equal 422, last_response.status
  end

  should "get community to logged user" do
    login_api
    community = fast_create(Community, environment_id: environment.id)

    get "/api/v1/communities/#{community.id}?#{params.to_query}"
    json = JSON.parse(last_response.body)
    assert_equal community.id, json["id"]
  end

  should "not list invisible community to logged users" do
    login_api
    community = fast_create(Community, environment_id: environment.id, visible: false)

    get "/api/v1/communities/#{community.id}?#{params.to_query}"
    assert_equal Api::Status::Http::NOT_FOUND, last_response.status
  end

  should "not get private community content to non member" do
    login_api
    community = fast_create(Community, environment_id: environment.id, access: Entitlement::Levels.levels[:self])

    get "/api/v1/communities/#{community.id}?#{params.to_query}"
    assert_equal Api::Status::Http::NOT_FOUND, last_response.status
  end

  should "display admins community if optional_fields is passed as parameter" do
    login_api
    community = fast_create(Community, environment_id: environment.id)

    params[:optional_fields] = ["admins"]
    get "/api/v1/communities/#{community.id}?#{params.to_query}"
    json = JSON.parse(last_response.body)
    assert_equal community.id, json["id"]
    assert_equal [], json["admins"]
  end

  should "display admins community only if optional_fields is passed as parameter" do
    login_api
    community = fast_create(Community, environment_id: environment.id)

    get "/api/v1/communities/#{community.id}?#{params.to_query}"
    json = JSON.parse(last_response.body)
    assert_nil json["admins"]
  end

  should "get private community to logged member" do
    login_api
    community = fast_create(Community, environment_id: environment.id, access: Entitlement::Levels.levels[:self], visible: true)
    community.add_member(person)

    params[:optional_fields] = ["members"]
    get "/api/v1/communities/#{community.id}?#{params.to_query}"
    json = JSON.parse(last_response.body)
    assert_equal community.id, json["id"]
    assert_not_nil json["members"]
  end

  should "list person communities to logged user" do
    login_api
    community = fast_create(Community, environment_id: environment.id)
    fast_create(Community, environment_id: environment.id)
    community.add_member(person)

    get "/api/v1/people/#{person.id}/communities?#{params.to_query}"
    json = JSON.parse(last_response.body)
    assert_equivalent [community.id], json.map { |c| c["id"] }
  end

  should "not list person invisible communities to logged user" do
    login_api
    community1 = fast_create(Community, environment_id: environment.id)
    community2 = fast_create(Community, environment_id: environment.id, visible: false)
    community1.add_member(person)
    community2.add_member(person)

    get "/api/v1/people/#{person.id}/communities?#{params.to_query}"
    json = JSON.parse(last_response.body)
    assert_equivalent [community1.id], json.map { |c| c["id"] }
  end

  should "logged user list communities with pagination" do
    login_api
    community1 = fast_create(Community, created_at: 1.day.ago)
    community2 = fast_create(Community, created_at: 2.days.ago)

    params[:page] = 2
    params[:per_page] = 1
    get "/api/v1/communities?#{params.to_query}"
    json_page_two = JSON.parse(last_response.body)

    params[:page] = 1
    params[:per_page] = 1
    get "/api/v1/communities?#{params.to_query}"
    json_page_one = JSON.parse(last_response.body)

    assert_includes json_page_one.map { |a| a["id"] }, community1.id
    assert_not_includes json_page_one.map { |a| a["id"] }, community2.id

    assert_includes json_page_two.map { |a| a["id"] }, community2.id
    assert_not_includes json_page_two.map { |a| a["id"] }, community1.id
  end

  should "list communities with timestamp to logged user" do
    login_api
    community1 = fast_create(Community)
    community2 = fast_create(Community)

    community1.updated_at = Time.now.in_time_zone + 3.hours
    community1.save!

    params[:timestamp] = Time.now.in_time_zone + 1.hours
    get "/api/v1/communities/?#{params.to_query}"
    json = JSON.parse(last_response.body)

    assert_includes json.map { |a| a["id"] }, community1.id
    assert_not_includes json.map { |a| a["id"] }, community2.id
  end

  should "anonymous list only communities" do
    community = fast_create(Community, environment_id: environment.id)
    enterprise = fast_create(Enterprise, environment_id: environment.id) # should not list this enterprise

    get "/api/v1/communities?#{params.to_query}"
    json = JSON.parse(last_response.body)
    assert_not_includes json.map { |c| c["id"] }, enterprise.id
    assert_includes json.map { |c| c["id"] }, community.id
  end

  should "anonymous list all communities" do
    community1 = fast_create(Community, environment_id: environment.id)
    community2 = fast_create(Community, environment_id: environment.id)

    get "/api/v1/communities?#{params.to_query}"
    json = JSON.parse(last_response.body)
    assert_equivalent [community1.id, community2.id], json.map { |c| c["id"] }
  end

  should "not list invisible communities to anonymous" do
    community1 = fast_create(Community, environment_id: environment.id)
    fast_create(Community, environment_id: environment.id, visible: false)

    get "/api/v1/communities?#{params.to_query}"
    json = JSON.parse(last_response.body)
    assert_equal [community1.id], json.map { |c| c["id"] }
  end

  should "not list secret and private communities to anonymous" do
    community = fast_create(Community, environment_id: environment.id)
    fast_create(Community, environment_id: environment.id, secret: true)
    fast_create(Community, environment_id: environment.id,
                           access: Entitlement::Levels.levels[:self])

    get "/api/v1/communities?#{params.to_query}"
    json = JSON.parse(last_response.body)
    assert_equivalent [community.id], json.map { |c| c["id"] }
  end

  should "not create a community as an anonymous user" do
    params[:community] = { name: "some" }

    post "/api/v1/communities?#{params.to_query}"
    json = JSON.parse(last_response.body)
    assert_equal 401, last_response.status
  end

  should "get community for anonymous" do
    community = fast_create(Community, environment_id: environment.id)
    get "/api/v1/communities/#{community.id}"
    json = JSON.parse(last_response.body)
    assert_equal community.id, json["id"]
  end

  should "not get invisible community to anonymous user" do
    community = fast_create(Community, environment_id: environment.id, visible: false)
    get "/api/v1/communities/#{community.id}"
    assert_equal Api::Status::Http::NOT_FOUND, last_response.status
  end

  should "list public person communities to anonymous" do
    community = fast_create(Community, environment_id: environment.id)
    fast_create(Community, environment_id: environment.id)
    community.add_member(person)

    get "/api/v1/people/#{person.id}/communities?#{params.to_query}"
    json = JSON.parse(last_response.body)
    assert_equivalent [community.id], json.map { |c| c["id"] }
  end

  should "not list private person communities to anonymous" do
    community = fast_create(Community, environment_id: environment.id)
    fast_create(Community, environment_id: environment.id)
    person.access = Entitlement::Levels.levels[:self]
    person.save
    community.add_member(person)

    get "/api/v1/people/#{person.id}/communities?#{params.to_query}"
    assert_equal 403, last_response.status
  end

  should "list communities with pagination to anonymous" do
    community1 = fast_create(Community, created_at: 1.day.ago)
    community2 = fast_create(Community, created_at: 2.days.ago)

    params[:page] = 2
    params[:per_page] = 1
    get "/api/v1/communities?#{params.to_query}"
    json_page_two = JSON.parse(last_response.body)

    params[:page] = 1
    params[:per_page] = 1
    get "/api/v1/communities?#{params.to_query}"
    json_page_one = JSON.parse(last_response.body)

    assert_includes json_page_one.map { |a| a["id"] }, community1.id
    assert_not_includes json_page_one.map { |a| a["id"] }, community2.id

    assert_includes json_page_two.map { |a| a["id"] }, community2.id
    assert_not_includes json_page_two.map { |a| a["id"] }, community1.id
  end

  should "list communities with timestamp to anonymous " do
    community1 = fast_create(Community)
    community2 = fast_create(Community)

    community1.updated_at = Time.now.in_time_zone + 3.hours
    community1.save!

    params[:timestamp] = Time.now.in_time_zone + 1.hours
    get "/api/v1/communities/?#{params.to_query}"
    json = JSON.parse(last_response.body)

    assert_includes json.map { |a| a["id"] }, community1.id
    assert_not_includes json.map { |a| a["id"] }, community2.id
  end

  should "display public custom fields to anonymous if additional_data optional_field is passed as parameter" do
    CustomField.create!(name: "Rating", format: "string", customized_type: "Community", active: true, environment: Environment.default)
    some_community = fast_create(Community)
    some_community.custom_values = { "Rating" => { "value" => "Five stars", "public" => "true" } }
    some_community.save!

    params[:optional_fields] = "additional_data"
    get "/api/v1/communities/#{some_community.id}?#{params.to_query}"
    json = JSON.parse(last_response.body)
    assert json["additional_data"].has_key?("Rating")
    assert_equal "Five stars", json["additional_data"]["Rating"]
  end

  should "not display cateogories if it has no optional_field is passed as parameter" do
    some_community = fast_create(Community)
    some_community.save!
    get "/api/v1/communities/#{some_community.id}?#{params.to_query}"
    json = JSON.parse(last_response.body)
    assert_nil json["categories"]
  end

  should "display cateogories if it has optional_field passed as parameter" do
    some_community = fast_create(Community)
    some_community.save!
    params[:optional_fields] = "categories"
    get "/api/v1/communities/#{some_community.id}?#{params.to_query}"
    json = JSON.parse(last_response.body)
    assert_equal [], json["categories"]
  end

  should "not display public custom fields to anonymous if additional_data optional_field is not passed as parameter" do
    CustomField.create!(name: "Rating", format: "string", customized_type: "Community", active: true, environment: Environment.default)
    some_community = fast_create(Community)
    some_community.custom_values = { "Rating" => { "value" => "Five stars", "public" => "true" } }
    some_community.save!

    get "/api/v1/communities/#{some_community.id}?#{params.to_query}"
    json = JSON.parse(last_response.body)
    assert_nil json["additional_data"]
  end

  should "not display private custom fields to anonymous" do
    CustomField.create!(name: "Rating", format: "string", customized_type: "Community", active: true, environment: Environment.default)
    some_community = fast_create(Community)
    some_community.custom_values = { "Rating" => { "value" => "Five stars", "public" => "false" } }
    some_community.save!

    params[:optional_fields] = "additional_data"
    get "/api/v1/communities/#{some_community.id}?#{params.to_query}"
    json = JSON.parse(last_response.body)
    refute json["additional_data"].has_key?("Rating")
  end

  should "not display members value by default" do
    login_api
    community = fast_create(Community, environment_id: environment.id, access: Entitlement::Levels.levels[:self], visible: true)
    community.add_member(person)

    get "/api/v1/communities/#{community.id}?#{params.to_query}"
    json = JSON.parse(last_response.body)
    assert_equal community.id, json["id"]
    assert_nil json["members"]
  end

  should "display members values if optional field parameter is passed" do
    community = fast_create(Community, environment_id: environment.id)

    get "/api/v1/communities/#{community.id}?#{params.merge(optional_fields: [:members]).to_query}"
    json = JSON.parse(last_response.body)
    assert_equal community.id, json["id"]
    assert_not_nil json["members"]
  end

  should "display members values if optional_fields has members value as string in array" do
    community = fast_create(Community, environment_id: environment.id)

    get "/api/v1/communities/#{community.id}?#{params.merge(optional_fields: ['members']).to_query}"
    json = JSON.parse(last_response.body)
    assert_equal community.id, json["id"]
    assert_not_nil json["members"]
  end

  should "display members values if optional_fields has members value in array" do
    community = fast_create(Community, environment_id: environment.id)

    get "/api/v1/communities/#{community.id}?#{params.merge(optional_fields: ['members', 'another']).to_query}"
    json = JSON.parse(last_response.body)
    assert_equal community.id, json["id"]
    assert_not_nil json["members"]
  end

  should "display members values if optional_fields has members value as string" do
    community = fast_create(Community, environment_id: environment.id)

    get "/api/v1/communities/#{community.id}?#{params.merge(optional_fields: 'members').to_query}"
    json = JSON.parse(last_response.body)
    assert_equal community.id, json["id"]
    assert_not_nil json["members"]
  end

  should "search for communities" do
    community1 = fast_create(Community)
    community2 = fast_create(Community, name: "Rails Community")
    params[:search] = "rails"
    get "/api/v1/communities?#{params.to_query}"
    json = JSON.parse(last_response.body)
    assert_equal [community2.id], json.map { |c| c["id"] }
  end

  should "send inviation for comunity" do
    login_api
    community = fast_create(Community)
    community.add_admin(person)
    post "/api/v1/communities/#{community.id}/invite?#{params.to_query}"
    json = JSON.parse(last_response.body)
    assert_equal Api::Status::Http::CREATED, last_response.status
  end

  should "not send inviation for unexisting community " do
    login_api
    community = fast_create(Community)
    post "/api/v1/communities/100/invite?#{params.to_query}"
    json = JSON.parse(last_response.body)
    assert_equal Api::Status::Http::NOT_FOUND, last_response.status
  end

  should "not send inviation for comunity if user has no permission" do
    login_api
    community = fast_create(Community)
    post "/api/v1/communities/#{community.id}/invite?#{params.to_query}"
    json = JSON.parse(last_response.body)
    assert_equal Api::Status::Http::FORBIDDEN, last_response.status
  end

  should "not send invitation unlogged" do
    community = fast_create(Community)
    post "/api/v1/communities/#{community.id}/invite?#{params.to_query}"
    assert_equal Api::Status::Http::UNAUTHORIZED, last_response.status
  end

  should "the invitation response return success true if the inivitation was sent" do
    login_api
    community = fast_create(Community)
    community.add_admin(person)
    post "/api/v1/communities/#{community.id}/invite?#{params.to_query}"
    json = JSON.parse(last_response.body)
    assert json["success"]
  end

  should "the inviation response return the code #{Api::Status::Membership::INVITATION_SENT_TO_BE_PROCESSED}" do
    login_api
    community = fast_create(Community)
    community.add_admin(person)
    post "/api/v1/communities/#{community.id}/invite?#{params.to_query}"
    json = JSON.parse(last_response.body)
    assert_equal json["code"], Api::Status::Membership::INVITATION_SENT_TO_BE_PROCESSED
  end

  should "the inviation response have some message" do
    login_api
    community = fast_create(Community)
    community.add_admin(person)
    post "/api/v1/communities/#{community.id}/invite?#{params.to_query}"
    json = JSON.parse(last_response.body)
    assert_not_nil json["message"]
  end

  should "get membership state equal to #{Api::Status::Membership::NOT_MEMBER} when user is not member" do
    login_api
    person = fast_create(Person)
    community = fast_create(Community)
    params[:identifier] = person.identifier
    get "/api/v1/communities/#{community.id}/membership?#{params.to_query}"
    json = JSON.parse(last_response.body)
    assert_equal Api::Status::Membership::NOT_MEMBER, json["code"]
  end

  should "get membership state equal to #{Api::Status::Membership::WAITING_FOR_APPROVAL} when user is waiting approval" do
    login_api
    person = fast_create(Person)
    community = fast_create(Community)
    community.update_attribute(:closed, true)
    TaskMailer.stubs(:deliver_target_notification)
    task = create(AddMember, requestor_id: person.id, target_id: community.id, target_type: "Profile")
    params[:identifier] = person.identifier
    get "/api/v1/communities/#{community.id}/membership?#{params.to_query}"
    json = JSON.parse(last_response.body)
    assert_equal Api::Status::Membership::WAITING_FOR_APPROVAL, json["code"]
  end

  should "get membership state equal to #{Api::Status::Membership::MEMBER} when user is member" do
    login_api
    person = fast_create(Person)
    community = fast_create(Community)
    community.add_member(person)
    params[:identifier] = person.identifier
    get "/api/v1/communities/#{community.id}/membership?#{params.to_query}"
    json = JSON.parse(last_response.body)
    assert_equal Api::Status::Membership::MEMBER, json["code"]
  end
end
