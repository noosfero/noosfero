require_relative '../test_helper'

class EnvironmentDesignControllerTest < ActionController::TestCase

  def setup
    @controller = EnvironmentDesignController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    Noosfero::Plugin::Manager.any_instance.stubs(:enabled_plugins).returns([PeopleBlockPlugin.new])
  end

  should 'be able to edit PeopleBlock' do
    login_as(create_admin_user(Environment.default))
    b = PeopleBlock.create!
    e = Environment.default
    e.boxes.create!
    e.boxes.first.blocks << b
    get :edit, :id => b.id
    assert_tag :tag => 'input', :attributes => { :id => 'block_limit' }
  end

end
