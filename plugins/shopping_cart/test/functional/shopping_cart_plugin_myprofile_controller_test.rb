require File.dirname(__FILE__) + '/../../../../test/test_helper'
require File.dirname(__FILE__) + '/../../controllers/shopping_cart_plugin_myprofile_controller'

# Re-raise errors caught by the controller.
class ShoppingCartPluginMyprofileController; def rescue_action(e) raise e end; end

class ShoppingCartPluginMyprofileControllerTest < Test::Unit::TestCase

  def setup
    @controller = ShoppingCartPluginMyprofileController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    @enterprise = fast_create(Enterprise)
    @admin = create_user('admin').person
    @enterprise.add_admin(@admin)
    login_as(@admin.identifier)
  end
  attr_reader :enterprise

  should 'be able to enable shopping cart' do
    enterprise.shopping_cart = false
    enterprise.save
    post :edit, :profile => enterprise.identifier, :profile_attr => {:shopping_cart => '1'}
    enterprise.reload

    assert enterprise.shopping_cart
  end

  should 'be able to disable shopping cart' do
    enterprise.shopping_cart = true
    enterprise.save
    post :edit, :profile => enterprise.identifier, :profile_attr => {:shopping_cart => '0'}
    enterprise.reload

    assert !enterprise.shopping_cart
  end

  should 'be able to enable shopping cart delivery' do
    enterprise.shopping_cart_delivery = false
    enterprise.save
    post :edit, :profile => enterprise.identifier, :profile_attr => {:shopping_cart_delivery => '1'}
    enterprise.reload

    assert enterprise.shopping_cart_delivery
  end

  should 'be able to disable shopping cart delivery' do
    enterprise.shopping_cart_delivery = true
    enterprise.save
    post :edit, :profile => enterprise.identifier, :profile_attr => {:shopping_cart_delivery => '0'}
    enterprise.reload

    assert !enterprise.shopping_cart_delivery
  end

  should 'be able to choose the delivery price' do
    price = 4.35
    post :edit, :profile => enterprise.identifier, :profile_attr => {:shopping_cart_delivery_price => price}
    enterprise.reload
    assert enterprise.shopping_cart_delivery_price == price
  end
end
