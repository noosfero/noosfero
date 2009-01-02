require File.dirname(__FILE__) + '/../test_helper'
require 'my_profile_controller'

# Re-raise errors caught by the controller.
class MyProfileController; def rescue_action(e) raise e end; end

class OnlyForPersonTestController < MyProfileController
  requires_profile_class Person
  def index
    render :text => '<div>something</div>'
  end
end

class MyProfileControllerTest < Test::Unit::TestCase

  all_fixtures
  def setup
    @controller = MyProfileController.new
    @request    = ActionController::TestRequest.new
    @request.stubs(:ssl?).returns(true)
    @response   = ActionController::TestResponse.new
  end

  def test_local_files_reference
    @controller = OnlyForPersonTestController.new
    user = create_user('test_user').person
    assert_local_files_reference :get, :index, :profile => user.identifier
  end
  
  def test_valid_xhtml
    assert_valid_xhtml
  end
  
  def test_should_allow_person
    @controller = OnlyForPersonTestController.new
    person = create_user('random_joe')
    login_as('random_joe')

    get :index, :profile => 'random_joe'
    assert_response :success
  end

  def test_should_not_allow_bare_profile
    @controller = OnlyForPersonTestController.new
    org = Organization.create!(:identifier => 'hacking_institute', :name => 'Hacking Institute')
    create_user('random_joe')
    login_as('random_joe')

    get :index, :profile => 'hacking_institute'
    assert_response 403 # forbidden
  end

  should 'require ssl' do
    @controller = OnlyForPersonTestController.new
    org = Organization.create!(:identifier => 'hacking_institute', :name => 'Hacking Institute')

    @request.expects(:ssl?).returns(false).at_least_once
    get :index, :profile => 'hacking_institute'
    assert_redirected_to :protocol => 'https://'
  end

end
