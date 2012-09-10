require File.dirname(__FILE__) + '/../test_helper'
require 'templates_controller'

# Re-raise errors caught by the controller.
class TemplatesController; def rescue_action(e) raise e end; end

class TemplatesControllerTest < ActionController::TestCase

  all_fixtures
  def setup
    @controller = TemplatesController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    login_as(create_admin_user(Environment.default))
  end

  should 'create person template' do
    post :create_person_template, :name => 'Developer'
    assert Person['developer'].is_template
  end

  should 'create community template' do
    post :create_community_template, :name => 'Debian'
    assert Community['debian'].is_template
  end

  should 'create enterprise template' do
    post :create_enterprise_template, :name => 'Free Software Foundation'
    assert Enterprise['free-software-foundation'].is_template
  end
end

