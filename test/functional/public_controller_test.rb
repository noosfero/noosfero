require_relative '../test_helper'

class PublicControllerTest < ActionController::TestCase

  should 'inherit from ApplicationController' do
    assert_kind_of ApplicationController, PublicController.new
  end

end
