require File.dirname(__FILE__) + '/../test_helper'
require 'enterprise_validation_controller'

# Re-raise errors caught by the controller.
class EnterpriseValidationController; def rescue_action(e) raise e end; end

class EnterpriseValidationControllerTest < Test::Unit::TestCase

#  all_fixtures:users
all_fixtures
  def setup
    @controller = EnterpriseValidationController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    login_as 'ze'
  end

  should 'list pending validations on index' do
    flunk 'not yet'
  end

  should 'prompt for needed data when approving or rejecting enterprise' do
    flunk 'not yet'
  end

  should 'be able to actually validate enterprise on request' do
    flunk 'not yet'
  end

end
