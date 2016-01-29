require 'test_helper'

class AccountControllerTest < ActionController::TestCase

  should 'render signup page' do
    get :signup
  end

end
