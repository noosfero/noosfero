require 'test_helper'
require 'home_controller'

class ManageProductsControllerTest < ActionController::TestCase

  def setup
    @controller = ManageProductsController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    @enterprise = fast_create(Enterprise, name: 'test', identifier: 'test_ent')
    @user = create_user_with_permission('test_user', 'manage_products', @enterprise)
    @environment = @enterprise.environment
    @environment.enable('products_for_enterprises')
    login_as :test_user

    @environment.enabled_plugins += ['MetadataPlugin']
    @environment.save!
  end

  should "not crash on new products" do
    get :new, profile: @enterprise.identifier
  end

end
