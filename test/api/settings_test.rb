require_relative 'test_helper'

class SettingsTest < ActiveSupport::TestCase

  def setup
    create_and_activate_user
    login_api
    @environment = Environment.default
    @profile = fast_create(Profile)
  end

  attr_accessor :environment, :profile

  should 'get environment settings' do
    get "/api/v1/environments/#{environment.id}/settings?#{params.to_query}"
    json = JSON.parse(last_response.body)
    assert_equal json.keys, ['available_blocks']
  end

  should 'list all profile settings configuration' do
    profile = fast_create(Profile)
    get "/api/v1/profiles/#{profile.id}/settings?#{params.to_query}"
    json = JSON.parse(last_response.body)
    assert_equal json.keys, ['available_blocks']
  end

  should 'list available blocks for profile' do
    profile = fast_create(Profile)
    get "/api/v1/profiles/#{profile.id}/settings/available_blocks?#{params.to_query}"
    json = JSON.parse(last_response.body)
    blocks = json.map{|b| b['type']}
    assert_includes blocks, 'ProfileImageBlock'
  end

  should 'list available blocks for environment' do
    environment = Environment.default
    get "/api/v1/environments/#{environment.id}/settings/available_blocks?#{params.to_query}"
    json = JSON.parse(last_response.body)
    blocks = json.map{|b| b['type']}
    assert_includes blocks, 'CommunitiesBlock'
  end

end
