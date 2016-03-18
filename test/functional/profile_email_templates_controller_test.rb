require 'test_helper'

class ProfileEmailTemplatesControllerTest < ActionController::TestCase

  setup do
    @profile = fast_create(Community)
    @person = create_user_with_permission('templatemanager', 'manage_email_templates', @profile)
    @email_template = EmailTemplate.create!(:name => 'template', :owner => @profile)
    login_as(@person.user.login)
  end

  attr_accessor :profile, :person

  test "should get index" do
    get :index, :profile => profile.identifier
    assert_response :success
    assert_not_nil assigns(:email_templates)
  end

  test "should get new" do
    get :new, :profile => profile.identifier
    assert_response :success
  end

  test "should create email_template" do
    assert_difference('EmailTemplate.count') do
      post :create, email_template: { :name => 'test' }, :profile => profile.identifier
    end

    assert_redirected_to url_for(:action => :index)
  end

  test "should show email_template" do
    get :show, id: @email_template, :profile => profile.identifier
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @email_template, :profile => profile.identifier
    assert_response :success
  end

  test "should update email_template" do
    put :update, id: @email_template, email_template: {  }, :profile => profile.identifier
    assert_redirected_to url_for(:action => :index)
  end

  test "should destroy email_template" do
    assert_difference('EmailTemplate.count', -1) do
      delete :destroy, id: @email_template, :profile => profile.identifier
    end

    assert_redirected_to url_for(:action => :index)
  end

  test "should get parsed template" do
    environment = Environment.default
    @email_template.subject = '{{profile_name}} - {{environment_name}}'
    @email_template.body = '{{profile_name}} - {{environment_name}}'
    @email_template.save!
    get :show_parsed, id: @email_template, :profile => profile.identifier
    assert_response :success
    json_response = ActiveSupport::JSON.decode(@response.body)
    assert_equal "#{@person.name} - #{environment.name}", json_response['parsed_subject']
    assert_equal "#{@person.name} - #{environment.name}", json_response['parsed_body']
  end

end
