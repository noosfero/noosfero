require_relative "test_helper"

class SessionTest < ActiveSupport::TestCase
  def setup
    create_and_activate_user
    login_api
  end

  should "should reset session on logout without current_user" do
    logout_api
    post "/api/v1/logout?#{params.to_query}"

    json = JSON.parse(last_response.body)
    assert_equal json["code"], Api::Status::LOGOUT
  end

  should "generate private token when login" do
    params = { login: "testapi", password: "testapi" }
    post "/api/v1/login?#{params.to_query}"
    json = JSON.parse(last_response.body)
    assert !json["private_token"].blank?
  end

  should "return 401 when login fails" do
    user.destroy
    params = { login: "testapi", password: "testapi" }
    post "/api/v1/login?#{params.to_query}"
    assert_equal 401, last_response.status
  end

  should "return 401 when login with an user that was not activated" do
    user.deactivate
    params = { login: "testapi", password: "testapi" }
    post "/api/v1/login?#{params.to_query}"
    assert_equal 401, last_response.status
  end

  should "register a user" do
    Environment.default.enable("skip_new_user_email_confirmation")
    params = { login: "newuserapi", password: "newuserapi", password_confirmation: "newuserapi", email: "newuserapi@email.com" }
    post "/api/v1/register?#{params.to_query}"
    assert_equal 201, last_response.status
    json = JSON.parse(last_response.body)
    assert User["newuserapi"].activated?
    assert json["activated"]
    assert json["private_token"].present?
  end

  should "register a user with name" do
    Environment.default.enable("skip_new_user_email_confirmation")
    params = { login: "newuserapi", password: "newuserapi", password_confirmation: "newuserapi", email: "newuserapi@email.com", name: "Little John" }
    post "/api/v1/register?#{params.to_query}"
    assert_equal 201, last_response.status
    json = JSON.parse(last_response.body)
    assert json["activated"]
    assert json["private_token"].present?
  end

  should "register an inactive user" do
    params = { login: "newuserapi", password: "newuserapi", password_confirmation: "newuserapi", email: "newuserapi@email.com" }
    post "/api/v1/register?#{params.to_query}"
    assert_equal 201, last_response.status
    json = JSON.parse(last_response.body)
    assert !json["activated"]
    assert json["private_token"].blank?
  end

  should "not register a user with invalid login" do
    params = { login: "c", password: "newuserapi", password_confirmation: "newuserapi", email: "newuserapi@email.com" }
    post "/api/v1/register?#{params.to_query}"
    json = JSON.parse(last_response.body)
    assert_equal 422, last_response.status
    assert_equal "too_short", json["errors"]["login"].first["error"]
  end

  should "return translated message when fail to register a user with invalid login" do
    I18n.locale = "pt-BR"
    params = { lang: "pt-BR", login: "c", password: "newuserapi", password_confirmation: "newuserapi", email: "newuserapi@email.com" }
    post "/api/v1/register?#{params.to_query}"
    json = JSON.parse(last_response.body)
    assert_equal 422, last_response.status
    assert_match /muito curto/, json["errors"]["login"].first["full_message"]
  end

  should "not register a user without email" do
    params = { login: "newuserapi", password: "newuserapi", password_confirmation: "newuserapi", email: nil }
    post "/api/v1/register?#{params.to_query}"
    json = JSON.parse(last_response.body)
    assert_equal 422, last_response.status
    assert_equal "blank", json["errors"]["email"].first["error"]
  end

  should "not register a duplicated user" do
    params = { login: "newuserapi", password: "newuserapi", password_confirmation: "newuserapi", email: "newuserapi@email.com" }
    post "/api/v1/register?#{params.to_query}"
    post "/api/v1/register?#{params.to_query}"
    json = JSON.parse(last_response.body)
    assert_equal 422, last_response.status
    assert_equal "taken", json["errors"]["login"].first["error"]
    assert_equal "taken", json["errors"]["email"].first["error"]
  end

  # TODO: Add another test cases to check register situations
  should "activate a user" do
    params = {
      login: "newuserapi",
      password: "newuserapi",
      password_confirmation: "newuserapi",
      email: "newuserapi@email.com"
    }
    user = User.new(params)
    user.save!

    params = { activation_token: user.activation_code,
               short_activation_code: user.short_activation_code }
    patch "/api/v1/activate?#{params.to_query}"
    assert_equal 200, last_response.status
  end

  should "do not activate a user if admin must approve him" do
    params = {
      login: "newuserapi",
      password: "newuserapi",
      password_confirmation: "newuserapi",
      email: "newuserapi@email.com",
      environment: Environment.default
    }
    user = User.new(params)
    user.environment.enable("admin_must_approve_new_users")
    user.save!

    params = { activation_token: user.activation_code,
               short_activation_code: user.short_activation_code }
    patch "/api/v1/activate?#{params.to_query}"
    assert_equal 202, last_response.status
    assert_equal "Waiting for admin moderate user registration", JSON.parse(last_response.body)["message"]
  end

  should "not activate a user if the token is invalid" do
    params = {
      login: "newuserapi",
      password: "newuserapi",
      password_confirmation: "newuserapi",
      email: "newuserapi@email.com",
      environment: Environment.default
    }
    user = User.new(params)
    user.save!

    params = { activation_token: "70250abe20cc6a67ef9399cf3286cb998b96aeaf",
               short_activation_code: user.short_activation_code }
    patch "/api/v1/activate?#{params.to_query}"
    assert_equal 412, last_response.status
  end

  should "not activate a user if short code is not correct" do
    params = {
      login: "newuserapi",
      password: "newuserapi",
      password_confirmation: "newuserapi",
      email: "newuserapi@email.com",
      environment: Environment.default
    }
    user = User.new(params)
    user.save!

    params = { activation_token: user.activation_code,
               short_activation_code: "nope00" }
    patch "/api/v1/activate?#{params.to_query}"
    assert_equal 412, last_response.status
  end

  should "create task to change password by user login" do
    params = { value: user.login }
    assert_difference "ChangePassword.count" do
      post "/api/v1/forgot_password?#{params.to_query}"
    end
  end

  should "not create task to change password when user is not found" do
    params = { value: "wronglogin" }
    assert_no_difference "ChangePassword.count" do
      post "/api/v1/forgot_password?#{params.to_query}"
    end
    assert_equal 404, last_response.status
  end

  should "change user password and close task" do
    task = ChangePassword.create!(requestor: @person)
    params.merge!(code: task.code, password: "secret", password_confirmation: "secret")
    patch "/api/v1/new_password?#{params.to_query}"
    assert_equal Task::Status::FINISHED, task.reload.status
    assert user.reload.authenticated?("secret")
    json = JSON.parse(last_response.body)
    assert_equal user.id, json["id"]
  end

  should "do not change user password when password confirmation is wrong" do
    task = ChangePassword.create!(requestor: user.person)
    params = { code: task.code, password: "secret", password_confirmation: "s3cret" }
    patch "/api/v1/new_password?#{params.to_query}"
    assert_equal Task::Status::ACTIVE, task.reload.status
    assert !user.reload.authenticated?("secret")
    json = JSON.parse(last_response.body)
    assert_match /doesn't match/, json["errors"]["password_confirmation"].first["full_message"]
    assert_equal 422, last_response.status
  end

  should "render not found when provide a wrong code on password change" do
    params = { code: "wrongcode", password: "secret", password_confirmation: "secret" }
    patch "/api/v1/new_password?#{params.to_query}"
    json = JSON.parse(last_response.body)
    assert_match /Couldn't find/, json["message"]

    assert_equal 400, last_response.status
  end

  should "not return private token when the registered user is inactive" do
    params = { login: "newuserapi", password: "newuserapi", password_confirmation: "newuserapi", email: "newuserapi@email.com" }
    post "/api/v1/register?#{params.to_query}"
    assert_equal 201, last_response.status
    json = JSON.parse(last_response.body)
    assert !User["newuserapi"].activated?
    assert !json["activated"]
    assert !json["private_token"].present?
  end

  should "resend activation code for an inactive user" do
    another_user = User.create!(login: "userlogin", password: "testapi", password_confirmation: "testapi", email: "test2@test.org", environment: @environment)
    params = { value: another_user.login }
    Delayed::Job.destroy_all
    assert_difference "ActionMailer::Base.deliveries.size" do
      post "/api/v1/resend_activation_code?#{params.to_query}"
      process_delayed_job_queue
    end
    json = JSON.parse(last_response.body)
    refute json.first["private_token"]
    assert_equal another_user.email, ActionMailer::Base.deliveries.last["to"].to_s
  end

  should "not resend activation code for an active user" do
    params = { value: user.login }
    Delayed::Job.destroy_all
    assert_no_difference "ActionMailer::Base.deliveries.size" do
      post "/api/v1/resend_activation_code?#{params.to_query}"
      process_delayed_job_queue
    end
    json = JSON.parse(last_response.body)
    assert json.first["private_token"]
  end

  should "authenticate from plugin when fail to login with user/password" do
    user = create_user
    user.activate!
    class Plugin1 < Noosfero::Plugin
      def alternative_authentication
        User.last
      end
    end
    Noosfero::Plugin.stubs(:all).returns([Plugin1.name])
    Environment.default.enable_plugin(Plugin1)

    params = { login: "testplugin", password: "testplugin" }
    post "/api/v1/login?#{params.to_query}"
    json = JSON.parse(last_response.body)
    assert json["private_token"].present?
  end
end
