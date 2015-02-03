require_relative "../test_helper"
require 'admin_controller'

# Re-raise errors caught by the controller.
class AdminController; def rescue_action(e) raise e end; end

class AdminControllerTest < ActionController::TestCase

  should 'inherit from ApplicationController' do
    assert_kind_of ApplicationController, AdminController.new
  end

end
