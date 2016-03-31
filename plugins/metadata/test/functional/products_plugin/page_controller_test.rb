require 'test_helper'

if defined? ProductsPlugin
  module ProductsPlugin
    class ManageProductsControllerTest < ActionController::TestCase

      def setup
        @controller = PageController.new
        @request    = ActionController::TestRequest.new
        @response   = ActionController::TestResponse.new
        @enterprise = fast_create(Enterprise, name: 'test', identifier: 'test_ent')
        @user = create_user_with_permission('test_user', 'manage_products', @enterprise)
        login_as :test_user

        @enterprise.environment.enable_plugin 'MetadataPlugin'
      end

      should "not crash on new products" do
        get :new, profile: @enterprise.identifier
      end

    end
  end
end
