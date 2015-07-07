require_relative "../test_helper"
require 'admin_controller'

class AdminControllerTest < ActionController::TestCase

  should 'inherit from ApplicationController' do
    assert_kind_of ApplicationController, AdminController.new
  end

end
