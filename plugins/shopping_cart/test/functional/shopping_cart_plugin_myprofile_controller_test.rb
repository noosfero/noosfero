require 'test_helper'

class ShoppingCartPluginMyprofileControllerTest < ActionController::TestCase

  def setup
    @profile = fast_create(Enterprise)
    @admin = create_user('admin').person
    @profile.add_admin(@admin)
    login_as(@admin.identifier)
  end
  attr_reader :profile

  should 'be able to enable shopping cart' do
    profile.shopping_cart_settings.enabled = false
    profile.shopping_cart_settings.save!

    post :edit, profile: profile.identifier, settings: {enabled: '1'}
    profile.reload

    assert profile.shopping_cart_settings.enabled
  end

  should 'be able to disable shopping cart' do
    profile.shopping_cart_settings.enabled = true
    profile.shopping_cart_settings.save!

    post :edit, profile: profile.identifier, settings: {enabled: '0'}
    profile.reload

    refute profile.shopping_cart_settings.enabled
  end

end
