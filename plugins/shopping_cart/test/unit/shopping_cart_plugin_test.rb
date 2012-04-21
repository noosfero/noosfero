require File.dirname(__FILE__) + '/../../../../test/test_helper'

class ShoppingCartPluginTest < ActiveSupport::TestCase

  def setup
    @shopping_cart = ShoppingCartPlugin.new
    @context = mock()
    @profile = mock()
    @profile.stubs(:identifier).returns('random-user')
    @context.stubs(:profile).returns(@profile)
    @shopping_cart.context = @context
    @shopping_cart.stubs(:profile).returns(@profile)
  end

  attr_reader :shopping_cart
  attr_reader :context

  should 'return true to stylesheet' do
    assert shopping_cart.stylesheet?
  end

  should 'not add button if product unavailable' do
    product = fast_create(Product, :available => false)
    enterprise = mock()
    enterprise.stubs(:shopping_cart).returns(true)

    assert_nil shopping_cart.add_to_cart_button(product, enterprise)
  end
end
