require_relative "../test_helper"

class EnvironmentDesignControllerTest < ActionDispatch::IntegrationTest
  ALL_BLOCKS = [ArticleBlock, LoginBlock, RecentDocumentsBlock, EnterprisesBlock, CommunitiesBlock, LinkListBlock, FeedReaderBlock, SlideshowBlock, HighlightsBlock, CategoriesBlock, RawHTMLBlock, TagsCloudBlock]

  def setup
    Noosfero::Plugin::Manager.any_instance.stubs(:enabled_plugins).returns([])
  end

  should "indicate only actual blocks as such" do
    controller = EnvironmentDesignController.new
    controller.stubs(:boxes_holder).returns(Environment.default)
    controller.stubs(:user).returns(create_user.person)
    assert(controller.available_blocks.all? { |item| item.new.is_a? Block })
  end

  ALL_BLOCKS.map do |block|
    define_method "test_should_#{block.to_s}_is_available" do
      controller = EnvironmentDesignController.new
      controller.stubs(:boxes_holder).returns(Environment.default)
      controller.stubs(:user).returns(create_user.person)
      assert_includes controller.available_blocks, block
    end
  end

  should "all available block in test" do
    controller = EnvironmentDesignController.new
    controller.stubs(:boxes_holder).returns(Environment.default)
    controller.stubs(:user).returns(create_user.person)
    assert_equal ALL_BLOCKS, controller.available_blocks
  end

  should "be able to edit LinkListBlock" do
    login_as_rails5(create_admin_user(Environment.default))
    l = LinkListBlock.create!(links: [{ name: "link 1", address: "/address_1" }])
    Environment.default.boxes.create!
    Environment.default.boxes.first.blocks << l
    get edit_environment_design_path(l)
    assert_tag tag: "input", attributes: { name: "block[links][][name]" }
    assert_tag tag: "input", attributes: { name: "block[links][][address]" }
  end

  should "be able to save LinkListBlock" do
    login_as_rails5(create_admin_user(Environment.default))
    l = LinkListBlock.create!()
    Environment.default.boxes.create!
    Environment.default.boxes.first.blocks << l
    post save_environment_design_path(l), params: { block: { links: [{ name: "link 1", address: "/address_1" }] } }
    l.reload
    assert_equal [{ "name" => "link 1", "address" => "/address_1" }], l.links
  end

  should "be able to edit ArticleBlock with portal community" do
    login_as_rails5(create_admin_user(Environment.default))
    l = ArticleBlock.create!
    e = Environment.default
    e.boxes.create!
    e.boxes.first.blocks << l
    community = mock()
    Environment.any_instance.stubs(:portal_community).returns(community)
    article = fast_create(Article)
    community.stubs(:articles).returns([article])
    get edit_environment_design_path(l)
    assert_tag tag: "select", attributes: { name: "block[article_id]" }
  end

  should "be able to edit ArticleBlock without portal community" do
    login_as_rails5(create_admin_user(Environment.default))
    l = ArticleBlock.create!
    e = Environment.default
    e.boxes.create!
    e.boxes.first.blocks << l
    community = mock()
    Environment.any_instance.expects(:portal_community).returns(nil)
    get edit_environment_design_path(l)
    assert_tag tag: "p", attributes: { id: "no_portal_community" }
  end

  should "be able to edit EnterprisesBlock" do
    login_as_rails5(create_admin_user(Environment.default))
    b = EnterprisesBlock.create!
    e = Environment.default
    e.boxes.create!
    e.boxes.first.blocks << b
    get edit_environment_design_path(b)
    assert_tag tag: "input", attributes: { id: "block_limit" }
  end

  should "be able to edit SlideshowBlock" do
    login_as_rails5(create_admin_user(Environment.default))
    b = SlideshowBlock.create!
    e = Environment.default
    e.boxes.create!
    e.boxes.first.blocks << b
    get edit_environment_design_path(b)
    assert_tag tag: "select", attributes: { id: "block_gallery_id" }
  end

  should "be able to edit LoginBlock" do
    login_as_rails5(create_admin_user(Environment.default))
    b = LoginBlock.create!
    e = Environment.default
    e.boxes.create!
    e.boxes.first.blocks << b
    get edit_environment_design_path(b)
    assert_tag tag: "input", attributes: { id: "block_title" }
  end

  should "be able to edit RecentDocumentsBlock" do
    login_as_rails5(create_admin_user(Environment.default))
    b = RecentDocumentsBlock.create!
    e = Environment.default
    e.boxes.create!
    e.boxes.first.blocks << b
    get edit_environment_design_path(b)
    assert_tag tag: "input", attributes: { id: "block_limit" }
  end

  should "be able to edit CommunitiesBlock" do
    login_as_rails5(create_admin_user(Environment.default))
    b = CommunitiesBlock.create!
    e = Environment.default
    e.boxes.create!
    e.boxes.first.blocks << b
    get edit_environment_design_path(b)
    assert_tag tag: "input", attributes: { id: "block_limit" }
  end

  should "be able to edit FeedReaderBlock" do
    login_as_rails5(create_admin_user(Environment.default))
    b = FeedReaderBlock.create!
    e = Environment.default
    e.boxes.create!
    e.boxes.first.blocks << b
    get edit_environment_design_path(b)
    assert_tag tag: "input", attributes: { id: "block_address" }
  end

  should "be able to edit TagsCloudBlock" do
    login_as_rails5(create_admin_user(Environment.default))
    b = TagsCloudBlock.create!
    e = Environment.default
    e.boxes.create!
    e.boxes.first.blocks << b
    get edit_environment_design_path(b)
    assert_tag tag: "input", attributes: { id: "block_title" }
  end

  should "create back link to environment control panel" do
    Environment.default.boxes.create!.blocks << CommunitiesBlock.new
    Environment.default.boxes.create!.blocks << EnterprisesBlock.new
    Environment.default.boxes.create!.blocks << LoginBlock.new
    login_as_rails5(create_admin_user(Environment.default))
    get environment_design_index_path

    assert_tag tag: "li", child: { tag: "a", attributes: { href: "/admin", class: "admin-link" } }
  end

  should "a environment block plugin add new blocks for environments" do
    controller = EnvironmentDesignController.new
    controller.stubs(:boxes_holder).returns(Environment.default)
    class CustomBlock1 < Block; end;

    class TestBlockPlugin < Noosfero::Plugin
      def self.extra_blocks
        {
          CustomBlock1 => { type: Environment },
        }
      end
    end
    controller.stubs(:user).returns(create_user.person)
    Noosfero::Plugin::Manager.any_instance.stubs(:enabled_plugins).returns([TestBlockPlugin.new])
    assert controller.available_blocks.include?(CustomBlock1)
  end

  should "a person, enterprise and community blocks plugins do not add new blocks for environments" do
    controller = EnvironmentDesignController.new
    controller.stubs(:boxes_holder).returns(Environment.default)
    controller.stubs(:user).returns(create_user.person)

    class CustomBlock1 < Block; end;
    class CustomBlock2 < Block; end;
    class CustomBlock3 < Block; end;
    class CustomBlock4 < Block; end;

    class TestBlockPlugin < Noosfero::Plugin
      def self.extra_blocks
        {
          CustomBlock1 => { type: Environment },
          CustomBlock2 => { type: Enterprise },
          CustomBlock3 => { type: Community },
          CustomBlock4 => { type: Person },
        }
      end
    end

    Noosfero::Plugin::Manager.any_instance.stubs(:enabled_plugins).returns([TestBlockPlugin.new])
    assert controller.available_blocks.include?(CustomBlock1)
    refute controller.available_blocks.include?(CustomBlock2)
    refute controller.available_blocks.include?(CustomBlock3)
    refute controller.available_blocks.include?(CustomBlock4)
  end

  should "a block plugin add new blocks" do
    class CustomBlock1 < Block; end;
    class CustomBlock2 < Block; end;
    class CustomBlock3 < Block; end;
    class CustomBlock4 < Block; end;
    class CustomBlock5 < Block; end;
    class CustomBlock6 < Block; end;
    class CustomBlock7 < Block; end;
    class CustomBlock8 < Block; end;
    class CustomBlock9 < Block; end;

    class TestBlockPlugin < Noosfero::Plugin
      def self.extra_blocks
        {
          CustomBlock1 => { type: Environment, position: [1] },
          CustomBlock2 => { type: Environment, position: 1 },
          CustomBlock3 => { type: Environment, position: "1" },
          CustomBlock4 => { type: Environment, position: [2] },
          CustomBlock5 => { type: Environment, position: 2 },
          CustomBlock6 => { type: Environment, position: "2" },
          CustomBlock7 => { type: Environment, position: [3] },
          CustomBlock8 => { type: Environment, position: 3 },
          CustomBlock9 => { type: Environment, position: "3" },
        }
      end
    end

    Noosfero::Plugin::Manager.any_instance.stubs(:enabled_plugins).returns([TestBlockPlugin.new])
    login_as_rails5(create_admin_user(Environment.default))
    get environment_design_index_path
    assert_response :success

    (1..9).each { |i| assert_tag tag: "div", attributes: { "data-block-type" => "EnvironmentDesignControllerTest::CustomBlock#{i}" } }
  end

  should "a block plugin cannot be listed for unspecified types" do
    class CustomBlock1 < Block; end;
    class CustomBlock2 < Block; end;
    class CustomBlock3 < Block; end;
    class CustomBlock4 < Block; end;
    class CustomBlock5 < Block; end;
    class CustomBlock6 < Block; end;
    class CustomBlock7 < Block; end;
    class CustomBlock8 < Block; end;

    class TestBlockPlugin < Noosfero::Plugin
      def self.extra_blocks
        {
          CustomBlock1 => { type: Person, position: 1 },
          CustomBlock2 => { type: Community, position: 1 },
          CustomBlock3 => { type: Enterprise, position: 1 },
          CustomBlock4 => { type: Environment, position: 1 },
          CustomBlock5 => { type: Person, position: 2 },
          CustomBlock6 => { type: Community, position: 3 },
          CustomBlock7 => { type: Enterprise, position: 2 },
          CustomBlock8 => { type: Environment, position: 3 },
        }
      end
    end

    Noosfero::Plugin::Manager.any_instance.stubs(:enabled_plugins).returns([TestBlockPlugin.new])
    login_as_rails5(create_admin_user(Environment.default))
    get environment_design_index_path
    assert_response :success

    [4, 8].each { |i| assert_tag tag: "div", attributes: { "data-block-type" => "EnvironmentDesignControllerTest::CustomBlock#{i}" } }
    [1, 2, 3, 5, 6, 7].each { |i| !assert_tag tag: "div", attributes: { "data-block-type" => "EnvironmentDesignControllerTest::CustomBlock#{i}" } }
  end

  should "clone a block" do
    logout_rails5
    login_as_rails5(create_admin_user(Environment.default))
    block = TagsCloudBlock.create!
    assert_difference "TagsCloudBlock.count", 1 do
      post clone_block_environment_design_path(block)
      assert_response :redirect
    end
  end

  should "return a list of paths from portal related to the words used in the query search" do
    controller = EnvironmentDesignController.new
    controller.stubs(:boxes_holder).returns(Environment.default)
    env = Environment.default
    login_as_rails5(create_admin_user(env))
    community = fast_create(Community, environment_id: env)
    env.portal_community = community
    env.enable("use_portal_community")
    env.save
    controller.stubs(:boxes_holder).returns(env)
    article1 = fast_create(Article, profile_id: community.id, name: "Some thing")
    article2 = fast_create(Article, profile_id: community.id, name: "Some article")
    article3 = fast_create(Article, profile_id: community.id, name: "Not an article")

    get search_autocomplete_environment_design_index_path, params: { query: "Some" }, xhr: true

    json_response = ActiveSupport::JSON.decode(@response.body)

    assert_response :success
    assert_equal json_response.include?("/{portal}/" + article1.path), true
    assert_equal json_response.include?("/{portal}/" + article2.path), true
    assert_equal json_response.include?("/{portal}/" + article3.path), false
  end

  should "return empty if portal not configured" do
    env = Environment.default
    login_as_rails5(create_admin_user(env))

    get search_autocomplete_environment_design_index_path, params: { query: "Some" }, xhr: true

    json_response = ActiveSupport::JSON.decode(@response.body)

    assert_response :success
    assert_equal json_response, []
  end
end
