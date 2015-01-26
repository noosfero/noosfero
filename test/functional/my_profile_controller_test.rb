require_relative "../test_helper"
require 'my_profile_controller'

# Re-raise errors caught by the controller.
class MyProfileController; def rescue_action(e) raise e end; end

class OnlyForPersonTestController < MyProfileController
  requires_profile_class Person
  def index
    render :text => '<div>something</div>'
  end
end

class MyProfileControllerTest < ActionController::TestCase

  all_fixtures
  def setup
    @controller = MyProfileController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
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

end
