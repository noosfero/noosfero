require_relative "../test_helper"

class UsersControllerTest < ActionController::TestCase
  def setup
    @controller = UsersController.new

    @environment = Environment.default

    admin_user = create_admin_user(@environment)
    login_as(admin_user)
  end
  attr_accessor :environment

  should "not access without right permission" do
    create_user("guest")
    login_as "guest"
    get :index
    assert_response 403 # forbidden
  end

  should "grant access with right permission" do
    get :index
    assert_response :success
  end

  should "blank search results include activated and deactivated users" do
    deactivated = create_user("deactivated")
    deactivated.activated_at = nil
    deactivated.person.visible = false
    deactivated.save!
    get :index, q: ""
    assert_tag tag: "div", attributes: { id: /users-list/ }, descendant: { tag: "a", attributes: { title: /adminuser/ } }
    assert_tag tag: "div", attributes: { id: /users-list/ }, descendant: { tag: "a", attributes: { title: /deactivated/ } }
  end

  should "blank search include all users" do
    (1..5).each { |i|
      u = create_user("user" + i.to_s)
    }
    get :index, q: "" # blank search
    assert_tag tag: "div", attributes: { id: /users-list/ }, descendant: { tag: "a", attributes: { title: /adminuser/ } }
    (1..5).each { |i|
      u = "user" + i.to_s
      assert_tag tag: "div", attributes: { id: /users-list/ }, descendant: { tag: "a", attributes: { title: u } }
    }
  end

  should "search not include all users" do
    (1..5).each { |i|
      u = create_user("user" + i.to_s)
    }
    get :index, q: "er5" # search
    assert_tag tag: "div", attributes: { id: /users-list/ }, descendant: { tag: "a", attributes: { title: /user5/ } }
    (1..4).each { |i|
      u = "user" + i.to_s
      !assert_tag tag: "div", attributes: { id: /users-list/ }, descendant: { tag: "a", attributes: { title: u } }
    }
  end

  should "set admin role" do
    person = create_user.person
    assert_equal false, person.is_admin?
    post :set_admin_role, id: person.id, q: ""
    person.reload
    assert person.is_admin?
  end

  should "reset admin role" do
    person = create_user.person

    environment.add_admin(person)
    assert person.is_admin?

    post :reset_admin_role, id: person.id, q: ""
    person.reload
    refute person.is_admin?
  end

  should "activate user" do
    u = create_user()
    u.deactivate
    assert_equal false, u.activated?
    post :activate, id: u.person.id, q: ""
    u.reload
    assert u.activated?
  end

  should "deactivate user" do
    u = create_user()
    u.activated_at = Time.now.utc
    u.activation_code = nil
    u.person.visible = true
    assert u.activated?
    post :deactivate, id: u.person.id, q: ""
    u.reload
    assert_equal false, u.activated?
  end

  should "order users by name" do
    create_user("jeremy")
    create_user("bill")
    create_user("ana")
    create_user("creed")
    get :index

    assert_order ["ana", "bill", "creed", "jeremy"], assigns(:collection).map(&:name)
  end

  should "set filter to all_users by default" do
    get :index
    assert_equal "all_users", assigns(:filter)
  end

  should "response as XML to export users" do
    create_user("maryjane", email: "maryjane@mail.com")
    get :download, format: "xml", fields: ["name", "email"]
    assert_equal "text/xml", @response.content_type
    assert_match "maryjane", @response.body
    assert_match "maryjane@mail.com", @response.body
  end

  should "response as CSV to export users" do
    create_user("maryjane")
    get :download, format: "csv", fields: ["name"]
    assert_equal "text/csv", @response.content_type
    assert_match "maryjane", @response.body
  end

  should "filter users when downloading" do
    create_user("jhondoe")
    create_user("jhonbaz")
    create_user("maryjane")

    get :download, format: "csv", fields: ["name"], q: "jhon"
    assert_match "jhondoe", @response.body
    assert_match "jhonbaz", @response.body
    assert_no_match "maryjane", @response.body
  end

  should "include only selected fields" do
    create_user("jhondoe")

    get :download, format: "csv", fields: ["email"]
    assert_match "jhondoe@noosfero.org", @response.body
    assert_match "Last login at", @response.body
    assert_no_match "name", @response.body
  end

  should "be able to remove a person" do
    person = fast_create(Person, environment_id: environment.id)
    assert_difference "Person.count", -1 do
      post :destroy_user, id: person.id
    end
  end

  should "not crash if user does not exist" do
    person = fast_create(Person)

    assert_no_difference "Person.count" do
      post :destroy_user, id: 99999
    end
    assert_redirected_to action: "index"
  end

  should "redirect to index after send email with success" do
    post :send_mail, mailing: { subject: "Subject", body: "Body" }, recipients: { profile_admins: "false", env_admins: "false" }
    assert_redirected_to action: "index"
    assert_match /The e-mails are being sent/, session[:notice]
  end

  should "mailing recipients_roles should be empty when none is set" do
    post :send_mail, mailing: { subject: "Subject", body: "Body" }, recipients: { profile_admins: "false", env_admins: "false" }
    mailing = EnvironmentMailing.last
    assert_equal mailing.recipients_roles, []
  end

  should "mailing recipients_roles should be set correctly" do
    post :send_mail, mailing: { subject: "Subject", body: "Body" }, recipients: { profile_admins: "true", env_admins: "true" }
    mailing = EnvironmentMailing.last
    assert_equal mailing.recipients_roles, ["profile_admin", "environment_administrator"]
  end

  should "send mail to admins recipients" do
    admin_user = create_user("new_admin").person
    admin_user_2 = create_user("new_admin_2").person

    environment.add_admin admin_user
    environment.add_admin admin_user_2

    assert_difference "MailingSent.count", environment.admins.count do
      post :send_mail, mailing: { subject: "UnB", body: "Hail UnB" }, recipients: { profile_admins: "false", env_admins: "true" }
      process_delayed_job_queue
    end
  end
end
