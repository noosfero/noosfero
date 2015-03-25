require File.dirname(__FILE__) + '/../../../../test/test_helper'
require File.dirname(__FILE__) + '/../../../../app/controllers/public/invite_controller'

# Re-raise errors caught by the controller.
class InviteController; def rescue_action(e) raise e end; end

class InviteControllerTest < ActionController::TestCase

  def setup
    @controller = InviteController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    environment = Environment.default
    environment.enabled_plugins = ['StoaPlugin']
    environment.save!
  end

  should 'not enable access to invitation if the user has not an usp_id' do
    Task.create!(:code => 12345678)
    person_without_usp_id = User.create!(:login => 'user-without', :email => 'user-without@example.com', :password => 'test', :password_confirmation => 'test', :person_data => {:invitation_code => 12345678}).person

    login_as(person_without_usp_id.identifier)
    get :invite_friends, :profile => person_without_usp_id.identifier
    assert_response 403
    get :select_friends, :profile => person_without_usp_id.identifier
    assert_response 403
  end

  should 'enable access to invitation if the user has an usp_id' do
    person_with_usp_id = User.create!(:login => 'user-with', :email => 'user-with@example.com', :password => 'test', :password_confirmation => 'test', :person_data => {:usp_id => 12345678}).person

    login_as(person_with_usp_id.identifier)
    get :invite_friends, :profile => person_with_usp_id.identifier
    assert_response 200
    get :select_friends, :profile => person_with_usp_id.identifier, :contact_list => ContactList.create.id
    assert_response 200
  end

  should 'alow invitation even in organizations' do
    person_with_usp_id = User.create!(:login => 'user-with', :email => 'user-with@example.com', :password => 'test', :password_confirmation => 'test', :person_data => {:usp_id => 12345678}).person
    organization = fast_create(Organization)
    organization.add_admin(person_with_usp_id)

    login_as(person_with_usp_id.identifier)
    get :invite_friends, :profile => organization.identifier
    assert_response 200
    get :select_friends, :profile => organization.identifier, :contact_list => ContactList.create.id
    assert_response 200
  end

  should 'search friends profiles by usp_id' do
    person = User.create!(:login => 'john', :email => 'john@example.com', :password => 'test', :password_confirmation => 'test', :person_data => {:usp_id => 12345678}).person
    User.create!(:login => 'joseph', :email => 'joseph@example.com', :password => 'test', :password_confirmation => 'test', :person_data => {:usp_id => 12333333})

    admin = User.create!(:login => 'mary', :email => 'mary@example.com', :password => 'test', :password_confirmation => 'test', :person_data => {:usp_id => 11111111}).person
    organization = fast_create(Organization)
    organization.add_admin(admin)

    login_as(admin.identifier)
    get :search, :profile => organization.identifier, :q => '1234'

    assert_equal [{"id" => person.id, "name" => person.name}].to_json, @response.body
    assert_response 200
  end
end

