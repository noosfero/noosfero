require File.dirname(__FILE__) + '/../test_helper'
require 'profile_admin_controller'

# Re-raise errors caught by the controller.
class ProfileAdminController; def rescue_action(e) raise e end; end

class OnlyForPersonTestController < ProfileAdminController
  requires_profile_class Person
  design :holder => :profile
  def index
    render :text => '<div>something</div>'
  end
end

class ProfileAdminControllerTest < Test::Unit::TestCase

  all_fixtures
  def setup
    @controller = ProfileAdminController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  def test_should_allow_person
    @controller = OnlyForPersonTestController.new
    person = Person.new(:name => 'Random Joe')
    @controller.stubs(:profile).returns(person)

    get :index
    assert_response :success
  end

  def test_should_not_allow_bare_profile
    @controller = OnlyForPersonTestController.new
    org = Organization.new(:name => 'Hacking Institute')
    @controller.stubs(:profile).returns(org)

    get :index
    assert_response 403 # forbidden
  end
end
