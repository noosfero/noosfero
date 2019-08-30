require_relative "test_helper"

class BlocksTest < ActiveSupport::TestCase
  def setup
    create_and_activate_user
    login_api
    @environment = Environment.default
    @profile = fast_create(Profile)
  end

  attr_accessor :environment, :profile
  expose_attributes = %w(id type settings position enabled box_id)

  expose_attributes.each do |attr|
    should "expose block #{attr} attribute by default" do
      block = fast_create(Block, box_id: user.person.boxes.first.id)
      get "/api/v1/blocks/#{block.id}?#{params.to_query}"
      json = JSON.parse(last_response.body)
      assert json.has_key?(attr)
    end
  end

  should "get an environment block" do
    box = fast_create(Box, owner_id: environment.id, owner_type: Environment.name)
    block = fast_create(Block, box_id: box.id)
    get "/api/v1/blocks/#{block.id}?#{params.to_query}"
    json = JSON.parse(last_response.body)
    assert_equal block.id, json["id"]
  end

  should "get a profile block" do
    box = fast_create(Box, owner_id: profile.id, owner_type: Profile.name)
    block = fast_create(Block, box_id: box.id)
    get "/api/v1/blocks/#{block.id}?#{params.to_query}"
    json = JSON.parse(last_response.body)
    assert_equal block.id, json["id"]
  end

  should "get a profile block for a not logged in user" do
    logout_api
    box = fast_create(Box, owner_id: profile.id, owner_type: Profile.name)
    block = fast_create(Block, box_id: box.id)
    get "/api/v1/blocks/#{block.id}?#{params.to_query}"
    json = JSON.parse(last_response.body)
    assert_equal block.id, json["id"]
  end

  should "not get a profile block for a not logged in user" do
    logout_api
    profile = fast_create(Profile, access: Entitlement::Levels.levels[:self])
    box = fast_create(Box, owner_id: profile.id, owner_type: Profile.name)
    block = fast_create(Block, box_id: box.id)
    get "/api/v1/blocks/#{block.id}?#{params.to_query}"
    assert_equal 403, last_response.status
  end

  should "not get a profile block for an user without permission" do
    profile = fast_create(Profile, access: Entitlement::Levels.levels[:self])
    box = fast_create(Box, owner_id: profile.id, owner_type: Profile.name)
    block = fast_create(Block, box_id: box.id)
    get "/api/v1/blocks/#{block.id}?#{params.to_query}"
    assert_equal 403, last_response.status
  end

  should "get an invisible profile block for an user with permission" do
    profile = fast_create(Profile, access: Entitlement::Levels.levels[:self])
    profile.add_admin(person)
    box = fast_create(Box, owner_id: profile.id, owner_type: Profile.name)
    block = fast_create(Block, box_id: box.id)
    get "/api/v1/blocks/#{block.id}?#{params.to_query}"
    json = JSON.parse(last_response.body)
    assert_equal block.id, json["id"]
  end

  should "get a block for an user with permission in a private profile" do
    profile = fast_create(Profile, access: Entitlement::Levels.levels[:self])
    profile.add_admin(person)
    box = fast_create(Box, owner_id: profile.id, owner_type: Profile.name)
    block = fast_create(Block, box_id: box.id)
    get "/api/v1/blocks/#{block.id}?#{params.to_query}"
    json = JSON.parse(last_response.body)
    assert_equal block.id, json["id"]
  end

  should "display api content by default" do
    box = fast_create(Box, owner_id: environment.id, owner_type: Environment.name)
    block = fast_create(Block, box_id: box.id)
    get "/api/v1/blocks/#{block.id}?#{params.to_query}"
    json = JSON.parse(last_response.body)
    assert json.key?("api_content")
  end

  should "display api content of a specific block" do
    class SomeBlock < Block
      def api_content(params = {})
        { some_content: { name: "test" } }
      end
    end
    box = fast_create(Box, owner_id: environment.id, owner_type: Environment.name)
    block = fast_create(SomeBlock, box_id: box.id)
    get "/api/v1/blocks/#{block.id}?#{params.to_query}"
    json = JSON.parse(last_response.body)
    assert_equal "test", json["api_content"]["some_content"]["name"]
  end

  should "display api content of raw html block" do
    box = fast_create(Box, owner_id: environment.id, owner_type: Environment.name)
    block = fast_create(RawHTMLBlock, box_id: box.id)
    block.html = "<div>test</div>"
    block.save!
    get "/api/v1/blocks/#{block.id}?#{params.to_query}"
    json = JSON.parse(last_response.body)
    assert_equal "<div>test</div>", json["api_content"]["html"]
  end

  should "not allow block edition when user has not the permission for profile" do
    box = fast_create(Box, owner_id: profile.id, owner_type: Profile.name)
    block = fast_create(Block, box_id: box.id)
    post "/api/v1/blocks/#{block.id}?#{params.to_query}"
    assert_equal 403, last_response.status
  end

  should "allow block edition when user has permission to edit profile design" do
    box = fast_create(Box, owner_id: profile.id, owner_type: Profile.name)
    block = fast_create(Block, box_id: box.id)
    give_permission(person, "edit_profile_design", profile)
    params[:block] = { title: "block title" }
    post "/api/v1/blocks/#{block.id}?#{params.to_query}"
    json = JSON.parse(last_response.body)
    assert_equal 201, last_response.status
    assert_equal "block title", json["title"]
  end

  should "save custom block parameters" do
    box = fast_create(Box, owner_id: profile.id, owner_type: Profile.name)
    block = fast_create(RawHTMLBlock, box_id: box.id)
    Environment.default.add_admin(person)
    params[:block] = { title: "block title", html: "block content" }
    post "/api/v1/blocks/#{block.id}?#{params.to_query}"
    json = JSON.parse(last_response.body)
    assert_equal 201, last_response.status
    assert_equal "block content", json["api_content"]["html"]
  end

  should "list block permissions when get a block" do
    box = fast_create(Box, owner_id: profile.id, owner_type: Profile.name)
    block = fast_create(Block, box_id: box.id)
    give_permission(person, "edit_profile_design", profile)
    get "/api/v1/blocks/#{block.id}?#{params.to_query}"
    json = JSON.parse(last_response.body)
    assert_includes json["permissions"], "allow_edit"
  end

  should "get a block with params passed to api content" do
    class MyTestBlock < Block
      def api_content(params = {})
        params
      end
    end
    box = fast_create(Box, owner_id: environment.id, owner_type: Environment.name)
    block = fast_create(MyTestBlock, box_id: box.id)
    params["custom_param"] = "custom_value"
    get "/api/v1/blocks/#{block.id}?#{params.to_query}"
    json = JSON.parse(last_response.body)
    assert_equal "custom_value", json["api_content"]["custom_param"]
  end

  should "be able to upload images when updating a block" do
    box = fast_create(Box, owner_id: profile.id, owner_type: Profile.name)
    block = fast_create(RawHTMLBlock, box_id: box.id)
    Environment.default.add_admin(person)
    base64_image = create_base64_image
    params[:block] = { images_builder: [base64_image] }
    params[:optional_fields] = "images"
    post "/api/v1/blocks/#{block.id}?#{params.to_query}"
    json = JSON.parse(last_response.body)
    assert_equal 201, last_response.status
    assert_equal base64_image[:filename], json["images"].first["filename"]
    assert_equal 1, block.images.size
  end

  should "be able to update image not remove existing images" do
    box = fast_create(Box, owner_id: profile.id, owner_type: Profile.name)
    block = fast_create(RawHTMLBlock, box_id: box.id)
    Environment.default.add_admin(person)
    base64_image = create_base64_image
    params[:block] = { images_builder: [base64_image] }
    post "/api/v1/blocks/#{block.id}?#{params.to_query}"
    assert_equal 1, block.images.size

    base64_image = create_base64_image
    params[:block] = { images_builder: [base64_image] }
    post "/api/v1/blocks/#{block.id}?#{params.to_query}"
    assert_equal 2, block.images.size
  end

  should "be able to remove images when updating a block" do
    box = fast_create(Box, owner_id: profile.id, owner_type: Profile.name)
    Environment.default.add_admin(person)
    block = create(Block, box: box, images_builder: [{
                     uploaded_data: fixture_file_upload("/files/rails.png", "image/png")
                   }])
    base64_image = create_base64_image
    params[:block] = { images_builder: [{ remove_image: "true", id: block.images.first.id }] }
    post "/api/v1/blocks/#{block.id}?#{params.to_query}"
    json = JSON.parse(last_response.body)
    assert_equal 0, block.images.size
  end

  should "return forbidden when block type is not a constant declared" do
    params[:block_type] = "FakeBlock"
    get "/api/v1/profiles/#{person.id}/blocks/preview?#{params.to_query}"
    json = JSON.parse(last_response.body)
    assert_equal json["message"], "403 Forbidden"
  end

  should "return forbidden when block type is a constant declared but is not derived from Block" do
    params[:block_type] = "Article"
    get "/api/v1/profiles/#{person.id}/blocks/preview?#{params.to_query}"
    json = JSON.parse(last_response.body)
    assert_equal json["message"], "403 Forbidden"
  end

  should "unlogged user not be able to get preview of a profile Block" do
    logout_api
    community = fast_create(Community, environment_id: environment.id)
    params[:block_type] = "RawHTMLBlock"
    get "/api/v1/profiles/#{community.id}/blocks/preview?#{params.to_query}"
    json = JSON.parse(last_response.body)
    assert_nil json["api_content"]
    assert_equal json["message"], "403 Forbidden"
  end

  should "only user with permission see the preview of a profile Block" do
    community = fast_create(Community, environment_id: environment.id)
    params[:block_type] = "RawHTMLBlock"
    get "/api/v1/profiles/#{community.id}/blocks/preview?#{params.to_query}"
    json = JSON.parse(last_response.body)
    assert_nil json["api_content"]
    assert_equal json["message"], "403 Forbidden"
  end

  should "only user with edit_design permission see the preview of a profile Block" do
    community = fast_create(Community, environment_id: environment.id)
    community.add_member(person)
    give_permission(person, "edit_profile_design", profile)
    params[:block_type] = "RawHTMLBlock"
    get "/api/v1/profiles/#{community.id}/blocks/preview?#{params.to_query}"
    json = JSON.parse(last_response.body)
    assert_not_nil json["api_content"]
  end

  should "user with permissions different from edit_design should not see the preview of a profile Block" do
    community = fast_create(Community, environment_id: environment.id)
    login_api

    ["destroy_profile", "edit_profile", "post_content"].map do |permission|
      give_permission(person, permission, community)
    end
    params[:block_type] = "RawHTMLBlock"
    get "/api/v1/profiles/#{community.id}/blocks/preview?#{params.to_query}"
    json = JSON.parse(last_response.body)
    assert_nil json["api_content"]
    assert_equal json["message"], "403 Forbidden"
  end

  should "be able to get preview of CommunitiesBlock" do
    community = fast_create(Community, environment_id: environment.id)
    community.add_admin(person)
    params[:block_type] = "CommunitiesBlock"
    get "/api/v1/profiles/#{person.id}/blocks/preview?#{params.to_query}"
    json = JSON.parse(last_response.body)
    assert_includes json["api_content"]["communities"].map { |community| community["id"] }, community.id
  end

  should "be able to get preview of RawHTMLBlock" do
    params[:block_type] = "RawHTMLBlock"
    get "/api/v1/profiles/#{person.id}/blocks/preview?#{params.to_query}"
    json = JSON.parse(last_response.body)
    assert_nil json["api_content"]["html"]
  end

  should "be able to get preview of RecentDocumentsBlock" do
    article1 = fast_create(Article, profile_id: user.person.id, name: "Article 1")
    article2 = fast_create(Article, profile_id: user.person.id, name: "Article 2")
    params[:block_type] = "RecentDocumentsBlock"
    get "/api/v1/profiles/#{user.person.id}/blocks/preview?#{params.to_query}"
    json = JSON.parse(last_response.body)
    assert_equal 2, json["api_content"]["articles"].size
    assert_includes json["api_content"]["articles"].map { |article| article["id"] }, article1.id
    assert_includes json["api_content"]["articles"].map { |article| article["id"] }, article2.id
  end

  ["environment_id", "default", "context"].map do |env_id|
    define_method "test_should_return_forbidden_when_block_type_is_not_a_constant_declared_on_environment_with#{env_id}" do
      params[:block_type] = "FakeBlock"
      environment_id = (env_id == "environment_id") ? environment.id : env_id
      get "/api/v1/environments/#{environment_id}/blocks/preview?#{params.to_query}"
      json = JSON.parse(last_response.body)
      assert_equal json["message"], "403 Forbidden"
    end

    define_method "test_should_return_forbidden_when_block_type_is_a_constant_declared_but_is_not_derived_from_Block_on_envinronment_with_#{env_id}" do
      params[:block_type] = "Article"
      environment_id = (env_id == "environment_id") ? environment.id : env_id
      get "/api/v1/environments/#{environment_id}/blocks/preview?#{params.to_query}"
      json = JSON.parse(last_response.body)
      assert_equal json["message"], "403 Forbidden"
    end

    define_method "test_should_unlogged_user_not_be_able_to_get_preview_of_a_environment_Block_with_#{env_id}" do
      logout_api
      params[:block_type] = "RawHTMLBlock"
      environment_id = (env_id == "environment_id") ? environment.id : env_id
      get "/api/v1/environments/#{environment_id}/blocks/preview?#{params.to_query}"
      json = JSON.parse(last_response.body)
      assert_nil json["api_content"]
      assert_equal json["message"], "403 Forbidden"
    end

    define_method "test_should_only_user_with_permission_see_the_preview_of_a_environment_Block_with_#{env_id}" do
      params[:block_type] = "RawHTMLBlock"
      environment_id = (env_id == "environment_id") ? environment.id : env_id
      get "/api/v1/environments/#{environment_id}/blocks/preview?#{params.to_query}"
      json = JSON.parse(last_response.body)
      assert_nil json["api_content"]
      assert_equal json["message"], "403 Forbidden"
    end

    define_method "test_should_'only_user_with_edit_environment_design_permission_see_the_preview_of_a_environment_Block_with_#{env_id}" do
      give_permission(person, "edit_environment_design", environment)
      params[:block_type] = "RawHTMLBlock"
      environment_id = (env_id == "environment_id") ? environment.id : env_id
      get "/api/v1/environments/#{environment_id}/blocks/preview?#{params.to_query}"
      json = JSON.parse(last_response.body)
      assert_not_nil json["api_content"]
    end

    define_method "test_should_user_with_permissions_different_from_edit_environment_design_should_not_see_the_preview_of_a_environment_Block_with_#{env_id}" do
      login_api

      ["destroy_profile", "edit_profile", "post_content"].map do |permission|
        give_permission(person, permission, environment)
      end
      params[:block_type] = "RawHTMLBlock"
      environment_id = (env_id == "environment_id") ? environment.id : env_id
      get "/api/v1/environments/#{environment_id}/blocks/preview?#{params.to_query}"
      json = JSON.parse(last_response.body)
      assert_nil json["api_content"]
      assert_equal json["message"], "403 Forbidden"
    end

    define_method "test_should_be_able_to_get_preview_of_CommunitiesBlock_on_environment_with_#{env_id}" do
      community = fast_create(Community, environment_id: environment.id)
      environment.add_admin(person)
      params[:block_type] = "CommunitiesBlock"
      environment_id = (env_id == "environment_id") ? environment.id : env_id
      get "/api/v1/environments/#{environment_id}/blocks/preview?#{params.to_query}"
      json = JSON.parse(last_response.body)
      assert_includes json["api_content"]["communities"].map { |community| community["id"] }, community.id
    end

    define_method "test_should_be_able_to_get_preview_of_RawHTMLBlock_on_environment_with_#{env_id}" do
      params[:block_type] = "RawHTMLBlock"
      environment.add_admin(person)
      environment_id = (env_id == "environment_id") ? environment.id : env_id
      get "/api/v1/environments/#{environment_id}/blocks/preview?#{params.to_query}"
      json = JSON.parse(last_response.body)
      assert_nil json["api_content"]["html"]
    end

    define_method "test_should_be_able_to_get_preview_of_RecentDocumentsBlock_on_environment_with_#{env_id}" do
      Article.delete_all
      article1 = fast_create(Article, profile_id: user.person.id, name: "Article 1")
      article2 = fast_create(Article, profile_id: user.person.id, name: "Article 2")
      params[:block_type] = "RecentDocumentsBlock"
      environment.add_admin(person)
      get "/api/v1/environments/#{environment.id}/blocks/preview?#{params.to_query}"
      json = JSON.parse(last_response.body)
      assert_equal 2, json["api_content"]["articles"].size
      assert_includes json["api_content"]["articles"].map { |article| article["id"] }, article1.id
      assert_includes json["api_content"]["articles"].map { |article| article["id"] }, article2.id
    end
  end
end
