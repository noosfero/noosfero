require_relative 'test_helper'

class BoxesTest < ActiveSupport::TestCase

  def setup
    create_and_activate_user
    login_api
  end

  kinds= %w[Profile Community Person Enterprise Environment]
  kinds.each do |kind|
    should "get_boxes_from_#{kind.downcase.pluralize}" do
      context_obj = fast_create(kind.constantize)
      box = fast_create(Box, :owner_id => context_obj.id, :owner_type => (kind == 'Environment') ? 'Environment' : 'Profile')
      get "/api/v1/#{kind.downcase.pluralize}/#{context_obj.id}/boxes?#{params.to_query}"
      json = JSON.parse(last_response.body)
      assert_equal box.id, json.first["id"]
    end
  end

  should 'get boxes from default environment' do
    Environment.delete_all
    environment = fast_create(Environment, :is_default => true)
    box = fast_create(Box, :owner_id => environment.id, :owner_type => 'Environment')
    get "/api/v1/environments/default/boxes?#{params.to_query}"
    json = JSON.parse(last_response.body)
    assert_equal box.id, json.first["id"]
  end

  should 'get boxes from context environment' do
    env = fast_create(Environment, :is_default => true)
    env2 = fast_create(Environment).domains << Domain.new(:name => 'test.host')
    box = fast_create(Box, :owner_id => environment.id, :owner_type => 'Environment')
    get "/api/v1/environments/context/boxes?#{params.to_query}"

    json = JSON.parse(last_response.body)
    assert_equal box.id, json.first["id"]
  end

  should 'not display block api_content by default' do
    Environment.delete_all
    environment = fast_create(Environment, :is_default => true)
    box = fast_create(Box, :owner_id => environment.id, :owner_type => 'Environment')
    block = fast_create(Block, box_id: box.id)
    get "/api/v1/environments/default/boxes?#{params.to_query}"
    json = JSON.parse(last_response.body)
    assert !json.first["blocks"].first.key?('api_content')
  end

  should 'get blocks from boxes' do
    Environment.delete_all
    environment = fast_create(Environment, :is_default => true)
    box = fast_create(Box, :owner_id => environment.id, :owner_type => 'Environment')
    block = fast_create(Block, box_id: box.id)
    get "/api/v1/environments/default/boxes?#{params.to_query}"
    json = JSON.parse(last_response.body)
    assert_equal [block.id], json.first["blocks"].map {|b| b['id']}
  end

  should 'not list a block for not logged users' do
    logout_api
    profile = fast_create(Profile)
    box = fast_create(Box, :owner_id => profile.id, :owner_type => Profile.name)
    block = fast_create(Block, box_id: box.id)
    block.display = 'never'
    block.save!
    get "/api/v1/profiles/#{profile.id}/boxes?#{params.to_query}"
    json = JSON.parse(last_response.body)
    assert_equal [], json.first["blocks"].map {|b| b['id']}
  end

  should 'list a block with logged in display_user for a logged user' do
    profile = fast_create(Profile)
    box = fast_create(Box, :owner_id => profile.id, :owner_type => Profile.name)
    block = fast_create(Block, box_id: box.id)
    block.display_user = 'logged'
    block.save!
    get "/api/v1/profiles/#{profile.id}/boxes?#{params.to_query}"
    json = JSON.parse(last_response.body)
    assert_equal [block.id], json.first["blocks"].map {|b| b['id']}
  end

  should 'list a block with not logged in display_user for an admin user' do
    profile = fast_create(Profile)
    profile.add_admin(person)
    box = fast_create(Box, :owner_id => profile.id, :owner_type => Profile.name)
    block = fast_create(Block, box_id: box.id)
    block.display_user = 'not_logged'
    block.save!
    get "/api/v1/profiles/#{profile.id}/boxes?#{params.to_query}"
    json = JSON.parse(last_response.body)
    assert_equal [block.id], json.first["blocks"].map {|b| b['id']}
  end

  should 'not list boxes for user without permission' do
    profile = fast_create(Profile, public_profile: false)
    box = fast_create(Box, :owner_id => profile.id, :owner_type => Profile.name)
    block = fast_create(Block, box_id: box.id)
    get "/api/v1/profiles/#{profile.id}/boxes?#{params.to_query}"
    json = JSON.parse(last_response.body)
    assert_equal 403, last_response.status
  end
end
