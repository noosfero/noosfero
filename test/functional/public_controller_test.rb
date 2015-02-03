require_relative "../test_helper"
require 'public_controller'

# Re-raise errors caught by the controller.
class PublicController; def rescue_action(e) raise e end; end

class PublicControllerTest < ActionController::TestCase

  should 'inherit from ApplicationController' do
    assert_kind_of ApplicationController, PublicController.new
  end

end
