require File.dirname(__FILE__) + '/../test_helper'
require 'users_controller'

# Re-raise errors caught by the controller.
class UsersController; def rescue_action(e) raise e end; end

class UsersControllerTest < ActionController::TestCase

  def setup
    @controller = UsersController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new

    admin_user = create_user_with_permission('adminuser', 'manage_environment_users', Environment.default)
    login_as('adminuser')
  end

  should 'not access without right permission' do
    create_user('guest')
    login_as 'guest'
    get :index
    assert_response 403 # forbidden
  end

  should 'grant access with right permission' do
    admin_user = create_user_with_permission('admin_user', 'manage_environment_users', Environment.default)
    login_as('admin_user')

    get :index
    assert_response :success
  end

  should 'blank search results include activated and deactivated users' do
    deactivated = create_user('deactivated')
    deactivated.activated_at = nil
    deactivated.person.visible = false
    deactivated.save!
    get :index, :q => ''
    assert_tag :tag => 'div', :attributes => { :id => /users-list/ }, :descendant => {:tag => 'a', :attributes => {:title => /adminuser/}}    
    assert_tag :tag => 'div', :attributes => { :id => /users-list/ }, :descendant => {:tag => 'a', :attributes => {:title => /deactivated/}}    
  end
  
  should 'blank search include all users' do
    (1..5).each {|i|
      u = create_user('user'+i.to_s)
    }
    get :index, :q => '' # blank search
    assert_tag :tag => 'div', :attributes => { :id => /users-list/ }, :descendant => {:tag => 'a', :attributes => {:title => /adminuser/}}
    (1..5).each {|i|
      u = 'user'+i.to_s
      assert_tag :tag => 'div', :attributes => { :id => /users-list/ }, :descendant => {:tag => 'a', :attributes => {:title => u}}    
    }
  end
  
  should 'search not include all users' do
    (1..5).each {|i|
      u = create_user('user'+i.to_s)
    }
    get :index, :q => 'er5' # search
    assert_tag :tag => 'div', :attributes => { :id => /users-list/ }, :descendant => {:tag => 'a', :attributes => {:title => /user5/}}
    (1..4).each {|i|
      u = 'user'+i.to_s
      assert_no_tag :tag => 'div', :attributes => { :id => /users-list/ }, :descendant => {:tag => 'a', :attributes => {:title => u}}    
    }
  end
  
  should 'set admin role' do
    u = create_user()
    assert_equal false, u.person.is_admin?
    post :set_admin_role, :id => u.person.id, :q => ''
    u.reload
    assert u.person.is_admin?
  end

  should 'reset admin role' do
    u = create_user()
    e = Environment.default
    e.add_admin(u.person)
    u.reload
    assert u.person.is_admin?
    post :reset_admin_role, :id => u.person.id, :q => ''
    u.reload
    assert_equal false, u.person.is_admin?
  end

  should 'activate user' do
    u = create_user()
    assert_equal false, u.activated?
    post :activate, :id => u.person.id, :q => ''
    u.reload
    assert u.activated?
  end

  should 'deactivate user' do
    u = create_user()
    u.activated_at = Time.now.utc
    u.activation_code = nil
    u.person.visible = true
    assert u.activated?
    post :deactivate, :id => u.person.id, :q => ''
    u.reload
    assert_equal false, u.activated?
  end

  should 'response as XML to export users' do
    admin_user = create_user_with_permission('admin_user', 'manage_environment_users', Environment.default)
    login_as('admin_user')

    get :download, :format => 'xml'
    assert_equal 'text/xml', @response.content_type
  end

  should 'response as CSV to export users' do
    admin_user = create_user_with_permission('admin_user', 'manage_environment_users', Environment.default)
    login_as('admin_user')

    get :download, :format => 'csv'
    assert_equal 'text/csv', @response.content_type
    assert_equal 'name;email', @response.body.split("\n")[0]
  end

end
