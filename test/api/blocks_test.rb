require_relative 'test_helper'

class BlocksTest < ActiveSupport::TestCase

  def setup
    create_and_activate_user
    login_api
    @environment = Environment.default
    @profile = fast_create(Profile)
  end

  attr_accessor :environment, :profile

  should 'get an environment block' do
    box = fast_create(Box, :owner_id => environment.id, :owner_type => Environment.name)
    block = fast_create(Block, box_id: box.id)
    get "/api/v1/blocks/#{block.id}?#{params.to_query}"
    json = JSON.parse(last_response.body)
    assert_equal block.id, json["block"]["id"]
  end

  should 'get a profile block' do
    box = fast_create(Box, :owner_id => profile.id, :owner_type => Profile.name)
    block = fast_create(Block, box_id: box.id)
    get "/api/v1/blocks/#{block.id}?#{params.to_query}"
    json = JSON.parse(last_response.body)
    assert_equal block.id, json["block"]["id"]
  end

  should 'get a profile block for a not logged in user' do
    logout_api
    box = fast_create(Box, :owner_id => profile.id, :owner_type => Profile.name)
    block = fast_create(Block, box_id: box.id)
    get "/api/v1/blocks/#{block.id}?#{params.to_query}"
    json = JSON.parse(last_response.body)
    assert_equal block.id, json["block"]["id"]
  end

  should 'not get a profile block for a not logged in user' do
    logout_api
    profile = fast_create(Profile, public_profile: false)
    box = fast_create(Box, :owner_id => profile.id, :owner_type => Profile.name)
    block = fast_create(Block, box_id: box.id)
    get "/api/v1/blocks/#{block.id}?#{params.to_query}"
    assert_equal 403, last_response.status
  end

  should 'not get a profile block for an user without permission' do
    profile = fast_create(Profile, public_profile: false)
    box = fast_create(Box, :owner_id => profile.id, :owner_type => Profile.name)
    block = fast_create(Block, box_id: box.id)
    get "/api/v1/blocks/#{block.id}?#{params.to_query}"
    assert_equal 403, last_response.status
  end

  should 'get a block for an user with permission in a private profile' do
    profile = fast_create(Profile, public_profile: false)
    profile.add_admin(person)
    box = fast_create(Box, :owner_id => profile.id, :owner_type => Profile.name)
    block = fast_create(Block, box_id: box.id)
    get "/api/v1/blocks/#{block.id}?#{params.to_query}"
    json = JSON.parse(last_response.body)
    assert_equal block.id, json["block"]["id"]
  end
end
