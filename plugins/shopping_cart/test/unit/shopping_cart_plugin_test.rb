require File.dirname(__FILE__) + '/../../../../test/test_helper'

class ShoppingCartPluginTest < Test::Unit::TestCase

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

end
