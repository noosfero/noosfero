require File.dirname(__FILE__) + '/../test_helper'
require 'admin_controller'

# Re-raise errors caught by the controller.
class AdminController; def rescue_action(e) raise e end; end

class AdminControllerTest < Test::Unit::TestCase

  should 'inherit from ApplicationController' do
    assert_kind_of ApplicationController, AdminController.new
  end

end
