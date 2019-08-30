require_relative "../test_helper"

class ProfileDesignControllerTest < ActionDispatch::IntegrationTest
  COMMOM_BLOCKS = [ArticleBlock, InterestTagsBlock, TagsCloudBlock, RecentDocumentsBlock, ProfileInfoBlock, LinkListBlock, MyNetworkBlock, FeedReaderBlock, ProfileImageBlock, LocationBlock, SlideshowBlock, ProfileSearchBlock, HighlightsBlock, MenuBlock]
  PERSON_BLOCKS = COMMOM_BLOCKS + [FavoriteEnterprisesBlock, CommunitiesBlock, EnterprisesBlock]
  PERSON_BLOCKS_WITH_BLOG = PERSON_BLOCKS + [BlogArchivesBlock]

  ENTERPRISE_BLOCKS = COMMOM_BLOCKS + [DisabledEnterpriseMessageBlock, FansBlock]

  attr_reader :holder
  def setup
    @profile = @holder = create_user("designtestuser").person
    holder.save!

    @box1 = Box.new
    @box2 = Box.new
    @box3 = Box.new

    holder.boxes << @box1
    holder.boxes << @box2
    holder.boxes << @box3

    ###### BOX 1
    @b1 = ArticleBlock.new
    @box1.blocks << @b1

    @b2 = Block.new
    @box1.blocks << @b2

    ###### BOX 2
    @b3 = Block.new
    @box2.blocks << @b3

    @b4 = MainBlock.new
    @box2.blocks << @b4

    @b5 = Block.new
    @box2.blocks << @b5

    @b6 = Block.new
    @box2.blocks << @b6

    ###### BOX 3
    @b7 = Block.new
    @box3.blocks << @b7

    @b8 = Block.new
    @box3.blocks << @b8

    # @request.env['HTTP_REFERER'] = '/editor'

    holder.blocks(true)

    login_as_rails5("designtestuser")
  end
  attr_reader :profile

  ######################################################
  # BEGIN - tests for BoxOrganizerController features
  ######################################################
  def test_should_move_block_to_the_end_of_another_block
    # person = create_user('mylogin').person

    get move_block_profile_design_index_path(profile: "designtestuser"), params: { id: "block-#{@b1.id}", target: "end-of-box-#{@box2.id}" }
    # get move_block_profile_design_index_path(), params: {:id => "block-#{@b1.id}", :target => "end-of-box-#{@box2.id}"}

    @b1.reload
    @box2.reload

    assert_equal @box2, @b1.box
    assert @b1.in_list?
    assert_equal @box2.blocks.size, @b1.position # i.e. assert @b1.last?
  end

  def test_should_move_block_to_the_middle_of_another_block
    # block 4 is in box 2
    get move_block_profile_design_index_path("designtestuser"), params: { id: "block-#{@b1.id}", target: "before-block-#{@b4.id}" }

    @b1.reload
    @b4.reload

    assert_equal @b4.box, @b1.box
    assert @b1.in_list?
    assert_equal @b4.position - 1, @b1.position
  end

  def test_block_can_be_moved_up
    get move_block_profile_design_index_path("designtestuser"), params: { id: "block-#{@b4.id}", target: "before-block-#{@b3.id}" }

    @b4.reload
    @b3.reload

    assert_equal @b3.position - 1, @b4.position
  end

  def test_block_can_be_moved_down
    assert_equal [1, 2, 3], [@b3, @b4, @b5].map { |item| item.position }

    # b3 -> before b5
    get move_block_profile_design_index_path("designtestuser"), params: { id: "block-#{@b3.id}", target: "before-block-#{@b5.id}" }

    [@b3, @b4, @b5].each do |item|
      item.reload
    end

    assert_equal [1, 2, 3], [@b4, @b3, @b5].map { |item| item.position }
  end

  def test_move_block_should_redirect_when_not_called_via_ajax
    get move_block_profile_design_index_path(profile: "designtestuser"), params: { id: "block-#{@b3.id}", target: "before-block-#{@b5.id}" }
    assert_redirected_to action: "index"
  end

  def test_move_block_should_render_when_called_via_ajax
    get move_block_profile_design_index_path(profile: "designtestuser"), params: { id: "block-#{@b3.id}", target: "before-block-#{@b5.id}" }, xhr: true
    assert_template "move_block"
  end

  def test_should_be_able_to_move_block_directly_down
    post move_block_down_profile_design_path("designtestuser", @b1)
    assert_response :redirect

    @b1.reload
    @b2.reload

    assert_equal [1, 2], [@b2, @b1].map { |item| item.position }
  end

  def test_should_be_able_to_move_block_directly_up
    post move_block_up_profile_design_path("designtestuser", @b2)
    assert_response :redirect

    @b1.reload
    @b2.reload

    assert_equal [1, 2], [@b2, @b1].map { |item| item.position }
  end

  def test_should_remove_block
    assert_difference "Block.count", -1 do
      post remove_profile_design_path("designtestuser", @b2)
      assert_response :redirect
      assert_redirected_to action: "index"
    end
  end

  should "have options to display blocks" do
    get edit_profile_design_path({ profile: "designtestuser" }, @b1)
    %w[always home_page_only except_home_page never].each do |option|
      assert_tag :select, attributes: { name: "block[display]" },
                          descendant: { tag: "option", attributes: { value: option } }
    end
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
          CustomBlock1 => { type: Person, position: [1] },
          CustomBlock2 => { type: Person, position: 1 },
          CustomBlock3 => { type: Person, position: "1" },
          CustomBlock4 => { type: Person, position: [2] },
          CustomBlock5 => { type: Person, position: 2 },
          CustomBlock6 => { type: Person, position: "2" },
          CustomBlock7 => { type: Person, position: [3] },
          CustomBlock8 => { type: Person, position: 3 },
          CustomBlock9 => { type: Person, position: "3" },
        }
      end
    end

    Noosfero::Plugin::Manager.any_instance.stubs(:enabled_plugins).returns([TestBlockPlugin.new])
    get profile_design_index_path(profile: "designtestuser")
    assert_response :success

    (1..9).each { |i| assert_tag tag: "div", attributes: { "data-block-type" => "ProfileDesignControllerTest::CustomBlock#{i}" } }
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
    get profile_design_index_path("designtestuser")
    assert_response :success

    [1, 5].each { |i| assert_tag tag: "div", attributes: { "data-block-type" => "ProfileDesignControllerTest::CustomBlock#{i}" } }
    [2, 3, 4, 6, 7, 8].each { |i| !assert_tag tag: "div", attributes: { "data-block-type" => "ProfileDesignControllerTest::CustomBlock#{i}" } }
  end

  should "not edit main block with never option" do
    get edit_profile_design_path({ profile: "designtestuser" }, @b4)
    !assert_tag :select, attributes: { name: "block[display]" },
                         descendant: { tag: "option", attributes: { value: "never" } }
  end

  should "not edit main block with home_page_only option" do
    get edit_profile_design_path({ profile: "designtestuser" }, @b4)
    !assert_tag :select, attributes: { name: "block[display]" },
                         descendant: { tag: "option", attributes: { value: "home_page_only" } }
  end

  should "edit main block with always option" do
    get edit_profile_design_path({ profile: "designtestuser" }, @b4)

    assert_tag :select, attributes: { name: "block[display]" },
                        descendant: { tag: "option", attributes: { value: "always" } }
  end

  should "edit main block with except_home_page option" do
    get edit_profile_design_path({ profile: "designtestuser" }, @b4)
    assert_tag :select, attributes: { name: "block[display]" },
                        descendant: { tag: "option", attributes: { value: "except_home_page" } }
  end

  should "return a list of paths related to the words used in the query search" do
    article1 = fast_create(Article, profile_id: @profile.id, name: "Some thing")
    article2 = fast_create(Article, profile_id: @profile.id, name: "Some article")
    article3 = fast_create(Article, profile_id: @profile.id, name: "Not an article")

    get search_autocomplete_profile_design_index_path("designtestuser"), xhr: true, params: { query: "Some" }

    json_response = ActiveSupport::JSON.decode(@response.body)

    assert_response :success
    assert_equal json_response.include?("/{profile}/" + article1.path), true
    assert_equal json_response.include?("/{profile}/" + article2.path), true
    assert_equal json_response.include?("/{profile}/" + article3.path), false
  end

  ######################################################
  # END - tests for BoxOrganizerController features
  ######################################################

  ######################################################
  # BEGIN - tests for ProfileDesignController features
  ######################################################

  should "actually add a new block" do
    assert_difference "Block.count" do
      post move_block_profile_design_index_path("designtestuser"), params: { target: "end-of-box-#{@box1.id}", type: RecentDocumentsBlock.name }
      assert_redirected_to action: "index"
    end
  end

  should "not allow to create unknown types" do
    assert_no_difference "Block.count" do
      assert_raise ArgumentError do
        post move_block_profile_design_index_path("designtestuser"), params: { box_id: @box1.id, type: "PleaseLetMeCrackYourSite" }
      end
    end
  end

  should "provide edit screen for blocks" do
    # get edit_profile_design_path({:profile => 'designtestuser'},{:id => @b1})
    get edit_profile_design_url("designtestuser", @b1), params: { profile: "designtestuser", id: @b1 }
    #    get edit_profile_design_url('designtestuser', @b1)
    assert_template "edit"
    !assert_tag tag: "body" # e.g. no layout
  end

  should "be able to save a block" do
    post save_profile_design_path("designtestuser", @b1), params: { block: { article_id: 999 } }

    assert_redirected_to action: "index"

    @b1.reload
    assert_equal 999, @b1.article_id
  end

  should "not be able to save a non editable block" do
    Block.any_instance.expects(:editable?).returns(false)
    post save_profile_design_path("designtestuser", @b1), params: { block: {} }
    assert_response :forbidden
  end

  should "display back to control panel button" do
    get profile_design_index_path("designtestuser")
    assert_tag tag: "a", attributes: { class: "ctrl-panel", title: "Configure your personal account and content", href: "/myprofile/designtestuser" }
  end

  should "display available blocks in alphabetical order" do
    ProfileDesignController.any_instance.stubs(:available_blocks).returns([TagsCloudBlock, ArticleBlock])
    get profile_design_index_path("designtestuser")
    assert_equivalent assigns(:available_blocks), [ArticleBlock, TagsCloudBlock]
  end

  should "create back link to profile control panel" do
    p = Profile.create!(name: "test_profile", identifier: "test_profile")

    login_as_rails5(create_user_with_permission("test_user", "edit_profile_design", p).identifier)

    get profile_design_index_path(p.identifier)
    assert_tag tag: "a", attributes: { href: "/myprofile/test_user" }
  end

  should "offer to create blog archives block only if has blog" do
    holder.articles << Blog.new(name: "Blog test", profile: holder)

    get profile_design_index_path("designtestuser")

    assert_tag tag: "div", attributes: { "data-block-type" => "BlogArchivesBlock" }
  end

  should "not offer to create blog archives block if user dont have blog" do
    get profile_design_index_path("designtestuser")
    !assert_tag tag: "div", attributes: { "data-block-type" => "BlogArchivesBlock" }
  end

  should "offer to create feed reader block" do
    get profile_design_index_path("designtestuser")
    assert_tag tag: "div", attributes: { "data-block-type" => "FeedReaderBlock" }
  end

  should "be able to edit FeedReaderBlock" do
    @box1.blocks << FeedReaderBlock.new(address: "feed address")
    holder.blocks(true)

    get edit_profile_design_path("designtestuser", @box1.blocks[-1])

    assert_response :success
    assert_tag tag: "input", attributes: { name: "block[address]", value: "feed address" }
    assert_tag tag: "select", attributes: { name: "block[limit]" }
  end

  should "be able to save FeedReaderBlock configurations" do
    @box1.blocks << FeedReaderBlock.new(address: "feed address")
    holder.blocks(true)
    block = @box1.blocks.find_by(type: "FeedReaderBlock")

    post save_profile_design_path("designtestuser", block), params: { block: { address: "new feed address", limit: "20" } }

    block.reload

    assert_equal "new feed address", block.address
    assert_equal 20, block.limit
  end

  should "require login" do
    logout_rails5
    get profile_design_index_path(profile.identifier)
    assert_redirected_to login_account_index_path
  end

  should "not show sideboxes when render access denied" do
    another_profile = create_user("bobmarley").person
    get profile_design_index_path(another_profile.identifier)
    assert_tag tag: "div", attributes: { class: "no-boxes" }
    assert_tag tag: "div", attributes: { id: "access-denied" }
  end

  should "the person blocks are all available" do
    @controller = ProfileDesignController.new
    profile = Person.new
    profile.stubs(:has_blog?).returns(false)
    profile.stubs(:is_admin?).with(anything).returns(false)
    environment = mock
    profile.stubs(:environment).returns(environment)
    environment.stubs(:enabled?).returns(false)
    @controller.stubs(:profile).returns(profile)
    @controller.stubs(:user).returns(profile)
    @controller.stubs(:boxes_holder).returns(profile)
    Noosfero::Plugin::Manager.any_instance.stubs(:enabled_plugins).returns([])
    assert_equivalent PERSON_BLOCKS, @controller.available_blocks
  end

  should "the person with blog blocks are all available" do
    @controller = ProfileDesignController.new
    profile = Person.new
    profile.stubs(:has_blog?).returns(true)
    profile.stubs(:is_admin?).with(anything).returns(false)
    environment = mock
    profile.stubs(:environment).returns(environment)
    environment.stubs(:enabled?).returns(false)
    @controller.stubs(:profile).returns(profile)
    @controller.stubs(:user).returns(profile)
    @controller.stubs(:boxes_holder).returns(profile)
    Noosfero::Plugin::Manager.any_instance.stubs(:enabled_plugins).returns([])
    assert_equal [], @controller.available_blocks - PERSON_BLOCKS_WITH_BLOG
  end

  should "the enterprise blocks are all available" do
    @controller = ProfileDesignController.new
    profile = Enterprise.new
    profile.stubs(:has_blog?).returns(false)
    profile.stubs(:is_admin?).with(anything).returns(false)
    environment = mock
    profile.stubs(:environment).returns(environment)
    environment.stubs(:enabled?).returns(true)
    @controller.stubs(:profile).returns(profile)
    @controller.stubs(:user).returns(profile)
    @controller.stubs(:boxes_holder).returns(profile)
    Noosfero::Plugin::Manager.any_instance.stubs(:enabled_plugins).returns([])
    assert_equal [], @controller.available_blocks - ENTERPRISE_BLOCKS
  end

  should "allow admins to add RawHTMLBlock" do
    @controller = ProfileDesignController.new
    profile.stubs(:is_admin?).returns(true)
    @controller.stubs(:user).returns(profile)
    get profile_design_index_path("designtestuser")
    assert_tag tag: "div", attributes: { "data-block-type" => "RawHTMLBlock" }
  end

  should "not allow normal users to add RawHTMLBlock" do
    @controller = ProfileDesignController.new
    profile.stubs(:is_admin?).returns(false)
    @controller.stubs(:user).returns(profile)
    get profile_design_index_path("designtestuser")
    !assert_tag tag: "div", attributes: { "data-block-type" => "RawHTMLBlock" }
  end

  should "editing article block displays right selected article" do
    selected_article = fast_create(Article, profile_id: profile.id)
    ArticleBlock.any_instance.stubs(:article).returns(selected_article)
    get edit_profile_design_path("designtestuser", @b1)
    assert_tag tag: "option", attributes: { value: selected_article.id, selected: "selected" }
  end

  should "the block plugin add a new block" do
    @controller = ProfileDesignController.new
    profile = Person.new
    profile.stubs(:has_blog?).returns(false)
    profile.stubs(:is_admin?).with(anything).returns(false)
    environment = mock
    profile.stubs(:environment).returns(environment)
    environment.stubs(:enabled?).returns(false)
    @controller.stubs(:profile).returns(profile)
    @controller.stubs(:user).returns(profile)
    @controller.stubs(:boxes_holder).returns(profile)

    class CustomBlock1 < Block; end;

    class TestBlockPlugin < Noosfero::Plugin
      def self.extra_blocks
        {
          CustomBlock1 => {},
        }
      end
    end

    Noosfero::Plugin::Manager.any_instance.stubs(:enabled_plugins).returns([TestBlockPlugin.new])
    assert @controller.available_blocks.include?(CustomBlock1)
  end

  should "a person block plugin add new blocks for person profile" do
    @controller = ProfileDesignController.new
    profile = Person.new
    profile.stubs(:has_blog?).returns(false)
    profile.stubs(:is_admin?).with(anything).returns(false)
    environment = mock
    profile.stubs(:environment).returns(environment)
    environment.stubs(:enabled?).returns(false)
    @controller.stubs(:profile).returns(profile)
    @controller.stubs(:user).returns(profile)
    @controller.stubs(:boxes_holder).returns(profile)

    class CustomBlock1 < Block; end;

    class TestBlockPlugin < Noosfero::Plugin
      def self.extra_blocks
        {
          CustomBlock1 => { type: Person },
        }
      end
    end

    Noosfero::Plugin::Manager.any_instance.stubs(:enabled_plugins).returns([TestBlockPlugin.new])
    assert @controller.available_blocks.include?(CustomBlock1)
  end

  should "a community block plugin add new blocks for community profile" do
    @controller = ProfileDesignController.new
    profile = Community.new
    profile.stubs(:has_blog?).returns(false)
    profile.stubs(:is_admin?).with(anything).returns(false)
    environment = mock
    profile.stubs(:environment).returns(environment)
    environment.stubs(:enabled?).returns(false)
    @controller.stubs(:profile).returns(profile)
    @controller.stubs(:user).returns(profile)
    @controller.stubs(:boxes_holder).returns(profile)

    class CustomBlock1 < Block; end;

    class TestBlockPlugin < Noosfero::Plugin
      def self.extra_blocks
        {
          CustomBlock1 => { type: Community },
        }
      end
    end

    Noosfero::Plugin::Manager.any_instance.stubs(:enabled_plugins).returns([TestBlockPlugin.new])
    assert @controller.available_blocks.include?(CustomBlock1)
  end

  should "a enterprise block plugin add new blocks for enterprise profile" do
    @controller = ProfileDesignController.new
    profile = Enterprise.new
    person = Person.new
    profile.stubs(:has_blog?).returns(false)
    person.stubs(:is_admin?).with(anything).returns(false)
    environment = mock
    profile.stubs(:environment).returns(environment)
    environment.stubs(:enabled?).returns(false)
    @controller.stubs(:profile).returns(profile)
    @controller.stubs(:user).returns(person)
    @controller.stubs(:boxes_holder).returns(profile)

    class CustomBlock1 < Block; end;

    class TestBlockPlugin < Noosfero::Plugin
      def self.extra_blocks
        {
          CustomBlock1 => { type: Enterprise },
        }
      end
    end

    Noosfero::Plugin::Manager.any_instance.stubs(:enabled_plugins).returns([TestBlockPlugin.new])
    assert @controller.available_blocks.include?(CustomBlock1)
  end

  should "an environment block plugin not add new blocks for person profiles" do
    @controller = ProfileDesignController.new
    profile = Person.new
    profile.stubs(:has_blog?).returns(false)
    profile.stubs(:is_admin?).with(anything).returns(false)
    environment = mock
    profile.stubs(:environment).returns(environment)
    environment.stubs(:enabled?).returns(false)
    @controller.stubs(:profile).returns(profile)
    @controller.stubs(:user).returns(profile)
    @controller.stubs(:boxes_holder).returns(profile)

    class CustomBlock1 < Block; end;

    class TestBlockPlugin < Noosfero::Plugin
      def self.extra_blocks
        {
          CustomBlock1 => { type: Environment },
        }
      end
    end

    Noosfero::Plugin::Manager.any_instance.stubs(:enabled_plugins).returns([TestBlockPlugin.new])
    assert !@controller.available_blocks.include?(CustomBlock1)
  end

  should "clone a block" do
    block = create(ProfileImageBlock, box: profile.boxes.first)
    assert_difference "ProfileImageBlock.count", 1 do
      post clone_block_profile_design_path(profile.identifier, block)
      assert_response :redirect
    end
  end

  test "should forbid POST to save for uneditable blocks" do
    block = profile.blocks.last
    block.edit_modes = "none"
    block.save!

    post save_profile_design_path(profile.identifier, block)
    assert_response :forbidden
  end

  test "should forbid POST to move_block for fixed blocks" do
    block = profile.blocks.last
    block.move_modes = "none"
    block.save!

    post move_block_profile_design_index_path(profile: profile.identifier), params: { id: block.id, target: "end-of-box-#{@box3.id}" }
    assert_response :forbidden
  end

  should "guarantee main block is always visible to everybody" do
    get edit_profile_design_path("designtestuser", @b4)
    %w[logged not_logged followers].each do |option|
      !assert_tag :select, attributes: { name: "block[display_user]" },
                           descendant: { tag: "option", attributes: { value: option } }
    end
  end

  should "update selected categories in blocks" do
    env = Environment.default
    c1 = env.categories.build(name: "Test category 1"); c1.save!

    block = profile.blocks.last

    Block.any_instance.expects(:accept_category?).at_least_once.returns true

    get update_categories_profile_design_path(profile.identifier, block), params: { category_id: c1.id }, xhr: true

    assert_equal assigns(:current_category), c1
  end

  should "not fail when a profile has a tag block" do
    a = create(Article, name: "my article", profile_id: holder.id, tag_list: "tag")
    @box1.blocks << TagsCloudBlock.new
    get profile_design_index_path("designtestuser")
  end
end
