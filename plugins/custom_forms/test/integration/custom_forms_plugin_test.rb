require 'test_helper'

class CustomFormsPluginTest < ActionDispatch::IntegrationTest

  def setup
    Environment.default.enable_plugin(CustomFormsPlugin)
    @profile = fast_create(Community)
    @form = CustomFormsPlugin::Form.create!(name: 'F1', profile: @profile)
  end

  should 'add custom route to forms' do
    get "/profile/#{@profile.identifier}/query/#{@form.identifier}"
    assert_response :success
  end

  should 'add custom route to form results' do
    get "/profile/#{@profile.identifier}/query/#{@form.identifier}/results"
    assert_response :success
  end
end
