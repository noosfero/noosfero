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
    assert_equal block.id, json["id"]
  end

  should 'get a profile block' do
    box = fast_create(Box, :owner_id => profile.id, :owner_type => Profile.name)
    block = fast_create(Block, box_id: box.id)
    get "/api/v1/blocks/#{block.id}?#{params.to_query}"
    json = JSON.parse(last_response.body)
    assert_equal block.id, json["id"]
  end

  should 'get a profile block for a not logged in user' do
    logout_api
    box = fast_create(Box, :owner_id => profile.id, :owner_type => Profile.name)
    block = fast_create(Block, box_id: box.id)
    get "/api/v1/blocks/#{block.id}?#{params.to_query}"
    json = JSON.parse(last_response.body)
    assert_equal block.id, json["id"]
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

  should 'get an invisible profile block for an user with permission' do
    profile = fast_create(Profile, public_profile: false)
    profile.add_admin(person)
    box = fast_create(Box, :owner_id => profile.id, :owner_type => Profile.name)
    block = fast_create(Block, box_id: box.id)
    get "/api/v1/blocks/#{block.id}?#{params.to_query}"
    json = JSON.parse(last_response.body)
    assert_equal block.id, json["id"]
  end

  should 'get a block for an user with permission in a private profile' do
    profile = fast_create(Profile, public_profile: false)
    profile.add_admin(person)
    box = fast_create(Box, :owner_id => profile.id, :owner_type => Profile.name)
    block = fast_create(Block, box_id: box.id)
    get "/api/v1/blocks/#{block.id}?#{params.to_query}"
    json = JSON.parse(last_response.body)
    assert_equal block.id, json["id"]
  end

  should 'display api content by default' do
    box = fast_create(Box, :owner_id => environment.id, :owner_type => Environment.name)
    block = fast_create(Block, box_id: box.id)
    get "/api/v1/blocks/#{block.id}?#{params.to_query}"
    json = JSON.parse(last_response.body)
    assert json.key?('api_content')
  end

  should 'display api content of a specific block' do
    class SomeBlock < Block
      def api_content(params = {})
        {some_content: { name: 'test'} }
      end
    end
    box = fast_create(Box, :owner_id => environment.id, :owner_type => Environment.name)
    block = fast_create(SomeBlock, box_id: box.id)
    get "/api/v1/blocks/#{block.id}?#{params.to_query}"
    json = JSON.parse(last_response.body)
    assert_equal "test", json["api_content"]["some_content"]["name"]
  end

  should 'display api content of raw html block' do
    box = fast_create(Box, :owner_id => environment.id, :owner_type => Environment.name)
    block = fast_create(RawHTMLBlock, box_id: box.id)
    block.html = '<div>test</div>'
    block.save!
    get "/api/v1/blocks/#{block.id}?#{params.to_query}"
    json = JSON.parse(last_response.body)
    assert_equal "<div>test</div>", json["api_content"]["html"]
  end

  should 'not allow block edition when user has not the permission for profile' do
    box = fast_create(Box, :owner_id => profile.id, :owner_type => Profile.name)
    block = fast_create(Block, box_id: box.id)
    post "/api/v1/blocks/#{block.id}?#{params.to_query}"
    assert_equal 403, last_response.status
  end

  should 'allow block edition when user has permission to edit profile design' do
    box = fast_create(Box, :owner_id => profile.id, :owner_type => Profile.name)
    block = fast_create(Block, box_id: box.id)
    give_permission(person, 'edit_profile_design', profile)
    params[:block] = {title: 'block title'}
    post "/api/v1/blocks/#{block.id}?#{params.to_query}"
    json = JSON.parse(last_response.body)
    assert_equal 201, last_response.status
    assert_equal 'block title', json['title']
  end

  should 'save custom block parameters' do
    box = fast_create(Box, :owner_id => profile.id, :owner_type => Profile.name)
    block = fast_create(RawHTMLBlock, box_id: box.id)
    Environment.default.add_admin(person)
    params[:block] = {title: 'block title', html: "block content"}
    post "/api/v1/blocks/#{block.id}?#{params.to_query}"
    json = JSON.parse(last_response.body)
    assert_equal 201, last_response.status
    assert_equal 'block content', json['api_content']['html']
  end

  should 'list block permissions when get a block' do
    box = fast_create(Box, :owner_id => profile.id, :owner_type => Profile.name)
    block = fast_create(Block, box_id: box.id)
    give_permission(person, 'edit_profile_design', profile)
    get "/api/v1/blocks/#{block.id}?#{params.to_query}"
    json = JSON.parse(last_response.body)
    assert_includes json["permissions"], 'allow_edit'
  end

  should 'get a block with params passed to api content' do
    class MyTestBlock < Block
      def api_content(params = {})
        params
      end
    end
    box = fast_create(Box, :owner_id => environment.id, :owner_type => Environment.name)
    block = fast_create(MyTestBlock, box_id: box.id)
    params["custom_param"] = "custom_value"
    get "/api/v1/blocks/#{block.id}?#{params.to_query}"
    json = JSON.parse(last_response.body)
    assert_equal "custom_value", json["api_content"]["custom_param"]
  end

  should 'be able to upload images when updating a block' do
    box = fast_create(Box, :owner_id => profile.id, :owner_type => Profile.name)
    block = fast_create(RawHTMLBlock, box_id: box.id)
    Environment.default.add_admin(person)
    base64_image = create_base64_image
    params[:block] = {images_builder: [base64_image]}
    post "/api/v1/blocks/#{block.id}?#{params.to_query}"
    json = JSON.parse(last_response.body)
    assert_equal 201, last_response.status
    assert_equal base64_image[:filename], json['images'].first['filename']
    assert_equal 1, block.images.size
  end

  should 'be able to remove images when updating a block' do
    box = fast_create(Box, :owner_id => profile.id, :owner_type => Profile.name)
    Environment.default.add_admin(person)
    block = create(Block, box: box, images_builder: [{
      uploaded_data: fixture_file_upload('/files/rails.png', 'image/png')
    }])
    base64_image = create_base64_image
    params[:block] = {images_builder: [{remove_image: 'true', id: block.images.first.id}]}
    post "/api/v1/blocks/#{block.id}?#{params.to_query}"
    json = JSON.parse(last_response.body)
    assert_equal 0, block.images.size
  end

  should 'return forbidden when block type is not a constant declared' do
    params[:block_type] = 'FakeBlock'
    get "/api/v1/profiles/#{person.id}/blocks/preview?#{params.to_query}"
    json = JSON.parse(last_response.body)
    assert_equal json["message"], "403 Forbidden"
  end

  should 'return forbidden when block type is a constant declared but is not derived from Block' do
    params[:block_type] = 'Article'
    get "/api/v1/profiles/#{person.id}/blocks/preview?#{params.to_query}"
    json = JSON.parse(last_response.body)
    assert_equal json["message"], "403 Forbidden"
  end

  should 'be able to get preview of CommunitiesBlock' do
    community = fast_create(Community, :environment_id => environment.id)
    community.add_admin(person)
    params[:block_type] = 'CommunitiesBlock'
    get "/api/v1/profiles/#{person.id}/blocks/preview?#{params.to_query}"
    json = JSON.parse(last_response.body)
    assert_includes json["api_content"]['communities'].map{ |community| community['id'] }, community.id
  end

  should 'be able to get preview of RawHTMLBlock' do
    params[:block_type] = 'RawHTMLBlock'
    get "/api/v1/profiles/#{person.id}/blocks/preview?#{params.to_query}"
    json = JSON.parse(last_response.body)
    assert_nil json["api_content"]['html']
  end

  should 'be able to get preview of RecentDocumentsBlock' do
    article1 = fast_create(Article, :profile_id => user.person.id, :name => "Article 1")
    article2 = fast_create(Article, :profile_id => user.person.id, :name => "Article 2")
    params[:block_type] = 'RecentDocumentsBlock'
    get "/api/v1/profiles/#{user.person.id}/blocks/preview?#{params.to_query}"
    json = JSON.parse(last_response.body)
    assert_equal 2, json["api_content"]["articles"].size
    assert_includes json["api_content"]['articles'].map{ |article| article['id'] }, article1.id
    assert_includes json["api_content"]['articles'].map{ |article| article['id'] }, article2.id
  end

end
