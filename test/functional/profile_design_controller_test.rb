require_relative "../test_helper"
require 'profile_design_controller'

class ProfileDesignControllerTest < ActionController::TestCase

  COMMOM_BLOCKS = [ ArticleBlock, TagsBlock, RecentDocumentsBlock, ProfileInfoBlock, LinkListBlock, MyNetworkBlock, FeedReaderBlock, ProfileImageBlock, LocationBlock, SlideshowBlock, ProfileSearchBlock, HighlightsBlock ]
  PERSON_BLOCKS = COMMOM_BLOCKS + [ FavoriteEnterprisesBlock, CommunitiesBlock, EnterprisesBlock ]
  PERSON_BLOCKS_WITH_BLOG = PERSON_BLOCKS + [BlogArchivesBlock]

  ENTERPRISE_BLOCKS = COMMOM_BLOCKS + [DisabledEnterpriseMessageBlock, FeaturedProductsBlock, FansBlock, ProductCategoriesBlock]
  ENTERPRISE_BLOCKS_WITH_PRODUCTS_ENABLE = ENTERPRISE_BLOCKS + [ProductsBlock]

  attr_reader :holder
  def setup
    @controller = ProfileDesignController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new

    @profile = @holder = create_user('designtestuser').person
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

    @request.env['HTTP_REFERER'] = '/editor'

    holder.blocks(true)

    @controller.stubs(:boxes_holder).returns(holder)
    login_as 'designtestuser'

    @product_category = fast_create(ProductCategory)
  end
  attr_reader :profile

  ######################################################
  # BEGIN - tests for BoxOrganizerController features
  ######################################################
  def test_should_move_block_to_the_end_of_another_block
    get :move_block, :profile => 'designtestuser', :id => "block-#{@b1.id}", :target => "end-of-box-#{@box2.id}"

    @b1.reload
    @box2.reload

    assert_equal @box2, @b1.box
    assert @b1.in_list?
    assert_equal @box2.blocks.size, @b1.position # i.e. assert @b1.last?
  end

  def test_should_move_block_to_the_middle_of_another_block
    # block 4 is in box 2
    get :move_block, :profile => 'designtestuser', :id => "block-#{@b1.id}", :target => "before-block-#{@b4.id}"

    @b1.reload
    @b4.reload

    assert_equal @b4.box, @b1.box
    assert @b1.in_list?
    assert_equal @b4.position - 1, @b1.position
  end

  def test_block_can_be_moved_up
    get :move_block, :profile => 'designtestuser', :id => "block-#{@b4.id}", :target => "before-block-#{@b3.id}"

    @b4.reload
    @b3.reload

    assert_equal @b3.position - 1, @b4.position
  end

  def test_block_can_be_moved_down
    assert_equal [1,2,3], [@b3,@b4,@b5].map {|item| item.position}

    # b3 -> before b5
    get :move_block, :profile => 'designtestuser', :id => "block-#{@b3.id}", :target => "before-block-#{@b5.id}"

    [@b3,@b4,@b5].each do |item|
      item.reload
    end

    assert_equal [1,2,3],  [@b4, @b3, @b5].map {|item| item.position}
  end

  def test_move_block_should_redirect_when_not_called_via_ajax
    get :move_block, :profile => 'designtestuser', :id => "block-#{@b3.id}", :target => "before-block-#{@b5.id}"
    assert_redirected_to :action => 'index'
  end

  def test_move_block_should_render_when_called_via_ajax
    xml_http_request :get, :move_block, :profile => 'designtestuser', :id => "block-#{@b3.id}", :target => "before-block-#{@b5.id}"
    assert_template 'move_block'
  end

  def test_should_be_able_to_move_block_directly_down
    post :move_block_down, :profile => 'designtestuser', :id => @b1.id
    assert_response :redirect

    @b1.reload
    @b2.reload

    assert_equal [1,2], [@b2,@b1].map {|item| item.position}
  end

  def test_should_be_able_to_move_block_directly_up
    post :move_block_up, :profile => 'designtestuser', :id => @b2.id
    assert_response :redirect

    @b1.reload
    @b2.reload

    assert_equal [1,2], [@b2,@b1].map {|item| item.position}
  end

  def test_should_remove_block
    assert_difference 'Block.count', -1 do
      post :remove, :profile => 'designtestuser', :id => @b2.id
      assert_response :redirect
      assert_redirected_to :action => 'index'
    end
  end

  should 'have options to display blocks' do
    get :edit, :profile => 'designtestuser', :id => @b1.id
    %w[always home_page_only except_home_page never].each do |option|
      assert_tag :select, :attributes => {:name => 'block[display]'},
       :descendant => {:tag => 'option', :attributes => {:value => option}}
    end
  end

  should 'a block plugin add new blocks' do
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
          CustomBlock1 => {:type => Person, :position => [1]},
          CustomBlock2 => {:type => Person, :position => 1},
          CustomBlock3 => {:type => Person, :position => '1'},
          CustomBlock4 => {:type => Person, :position => [2]},
          CustomBlock5 => {:type => Person, :position => 2},
          CustomBlock6 => {:type => Person, :position => '2'},
          CustomBlock7 => {:type => Person, :position => [3]},
          CustomBlock8 => {:type => Person, :position => 3},
          CustomBlock9 => {:type => Person, :position => '3'},
        }
      end
    end

    Noosfero::Plugin::Manager.any_instance.stubs(:enabled_plugins).returns([TestBlockPlugin.new])
    get :index, :profile => 'designtestuser'
    assert_response :success

    (1..9).each {|i| assert_tag :tag => 'div', :attributes => { 'data-block-type' => "ProfileDesignControllerTest::CustomBlock#{i}" } }
  end

  should 'a block plugin cannot be listed for unspecified types' do
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
          CustomBlock1 => {:type => Person, :position => 1},
          CustomBlock2 => {:type => Community, :position => 1},
          CustomBlock3 => {:type => Enterprise, :position => 1},
          CustomBlock4 => {:type => Environment, :position => 1},
          CustomBlock5 => {:type => Person, :position => 2},
          CustomBlock6 => {:type => Community, :position => 3},
          CustomBlock7 => {:type => Enterprise, :position => 2},
          CustomBlock8 => {:type => Environment, :position => 3},
        }
      end
    end

    Noosfero::Plugin::Manager.any_instance.stubs(:enabled_plugins).returns([TestBlockPlugin.new])
    get :index, :profile => 'designtestuser'
    assert_response :success

    [1, 5].each {|i| assert_tag :tag => 'div', :attributes => { 'data-block-type' => "ProfileDesignControllerTest::CustomBlock#{i}" }}
    [2, 3, 4, 6, 7, 8].each {|i| assert_no_tag :tag => 'div', :attributes => { 'data-block-type' => "ProfileDesignControllerTest::CustomBlock#{i}" }}
  end

  should 'not edit main block with never option' do
    get :edit, :profile => 'designtestuser', :id => @b4.id
    assert_no_tag :select, :attributes => {:name => 'block[display]'},
      :descendant => {:tag => 'option', :attributes => {:value => 'never'}}
  end

  should 'not edit main block with home_page_only option' do
    get :edit, :profile => 'designtestuser', :id => @b4.id
    assert_no_tag :select, :attributes => {:name => 'block[display]'},
     :descendant => {:tag => 'option', :attributes => {:value => 'home_page_only'}}
  end

  should 'edit main block with always option' do
    get :edit, :profile => 'designtestuser', :id => @b4.id
    assert_tag :select, :attributes => {:name => 'block[display]'},
     :descendant => {:tag => 'option', :attributes => {:value => 'always'}}
  end

  should 'edit main block with except_home_page option' do
    get :edit, :profile => 'designtestuser', :id => @b4.id
    assert_tag :select, :attributes => {:name=> 'block[display]'},
     :descendant => {:tag => 'option', :attributes => {:value => 'except_home_page'}}
  end

  should 'return a list of paths related to the words used in the query search' do
    article1 = fast_create(Article, :profile_id => @profile.id, :name => "Some thing")
    article2 = fast_create(Article, :profile_id => @profile.id, :name => "Some article")
    article3 = fast_create(Article, :profile_id => @profile.id, :name => "Not an article")

    xhr :get, :search_autocomplete, :profile => 'designtestuser' , :query => 'Some'

    json_response = ActiveSupport::JSON.decode(@response.body)

    assert_response :success
    assert_equal json_response.include?("/{profile}/"+article1.path), true
    assert_equal json_response.include?("/{profile}/"+article2.path), true
    assert_equal json_response.include?("/{profile}/"+article3.path), false
  end

  ######################################################
  # END - tests for BoxOrganizerController features
  ######################################################

  ######################################################
  # BEGIN - tests for ProfileDesignController features
  ######################################################

  should 'actually add a new block' do
    assert_difference 'Block.count' do
      post :move_block, :profile => 'designtestuser', :target => "end-of-box-#{@box1.id}", :type => RecentDocumentsBlock.name
      assert_redirected_to :action => 'index'
    end
  end

  should 'not allow to create unknown types' do
    assert_no_difference 'Block.count' do
      assert_raise ArgumentError do
        post :move_block, :profile => 'designtestuser', :box_id => @box1.id, :type => "PleaseLetMeCrackYourSite"
      end
    end
  end

  should 'provide edit screen for blocks' do
    get :edit, :profile => 'designtestuser', :id => @b1.id
    assert_template 'edit'
    assert_no_tag :tag => 'body' # e.g. no layout
  end

  should 'be able to save a block' do
    post :save, :profile => 'designtestuser', :id => @b1.id, :block => { :article_id => 999 }

    assert_redirected_to :action => 'index'

    @b1.reload
    assert_equal 999, @b1.article_id
  end

  should 'not be able to save a non editable block' do
    Block.any_instance.expects(:editable?).returns(false)
    post :save, :profile => 'designtestuser', :id => @b1.id, :block => { }
    assert_response :forbidden
  end

  should 'be able to edit ProductsBlock' do
    block = ProductsBlock.new

    enterprise = fast_create(Enterprise, :name => "test", :identifier => 'testenterprise')
    enterprise.boxes << Box.new
    p1 = enterprise.products.create!(:name => 'product one', :product_category => @product_category)
    p2 = enterprise.products.create!(:name => 'product two', :product_category => @product_category)
    enterprise.boxes.first.blocks << block
    enterprise.add_admin(holder)

    enterprise.blocks(true)
    @controller.stubs(:boxes_holder).returns(enterprise)
    login_as('designtestuser')

    get :edit, :profile => 'testenterprise', :id => block.id

    assert_response :success
    assert_tag :tag => 'input', :attributes => { :name => "block[product_ids][]", :value => p1.id.to_s }
    assert_tag :tag => 'input', :attributes => { :name => "block[product_ids][]", :value => p2.id.to_s }
  end

  should 'be able to save ProductsBlock' do
    block = ProductsBlock.new

    enterprise = fast_create(Enterprise, :name => "test", :identifier => 'testenterprise')
    enterprise.boxes << Box.new
    p1 = enterprise.products.create!(:name => 'product one', :product_category => @product_category)
    p2 = enterprise.products.create!(:name => 'product two', :product_category => @product_category)
    enterprise.boxes.first.blocks << block
    enterprise.add_admin(holder)

    enterprise.blocks(true)
    @controller.stubs(:boxes_holder).returns(enterprise)
    login_as('designtestuser')

    post :save, :profile => 'testenterprise', :id => block.id, :block => { :product_ids => [p1.id.to_s, p2.id.to_s ] }

    assert_response :redirect

    block.reload
    assert_equal [p1.id, p2.id], block.product_ids

  end

  should 'display back to control panel button' do
    get :index, :profile => 'designtestuser'
    assert_tag :tag => 'a', :content => 'Back to control panel'
  end

  should 'display avaliable blocks in alphabetical order' do
    @controller.stubs(:available_blocks).returns([TagsBlock, ArticleBlock])
    get :index, :profile => 'designtestuser'
    assert_equal assigns(:available_blocks), [ArticleBlock, TagsBlock]
  end

  should 'not allow products block if environment do not let' do
    env = Environment.default
    env.disable('products_for_enterprises')
    env.save!
    ent = fast_create(Enterprise, :name => 'test ent', :identifier => 'test_ent', :environment_id => env.id)
    person = create_user_with_permission('test_user', 'edit_profile_design', ent)
    login_as(person.user.login)

    get :index, :profile => 'test_ent'

    assert_no_tag :tag => 'div', :attributes => { 'data-block-type' => 'ProductsBlock' }
  end

  should 'create back link to profile control panel' do
    p = Profile.create!(:name => 'test_profile', :identifier => 'test_profile')

    login_as(create_user_with_permission('test_user','edit_profile_design',p).identifier )
    get :index, :profile => p.identifier

    assert_tag :tag => 'a', :attributes => {:href => '/myprofile/test_profile'}
  end

  should 'offer to create blog archives block only if has blog' do
    holder.articles << Blog.new(:name => 'Blog test', :profile => holder)
    get :index, :profile => 'designtestuser'
    assert_tag :tag => 'div', :attributes => { 'data-block-type' => 'BlogArchivesBlock' }
  end

  should 'not offer to create blog archives block if user dont have blog' do
    get :index, :profile => 'designtestuser'
    assert_no_tag :tag => 'div', :attributes => { 'data-block-type' => 'BlogArchivesBlock' }
  end

  should 'offer to create feed reader block' do
    get :index, :profile => 'designtestuser'
    assert_tag :tag => 'div', :attributes => { 'data-block-type' => 'FeedReaderBlock' }
  end

  should 'be able to edit FeedReaderBlock' do
    @box1.blocks << FeedReaderBlock.new(:address => 'feed address')
    holder.blocks(true)

    get :edit, :profile => 'designtestuser', :id => @box1.blocks[-1].id

    assert_response :success
    assert_tag :tag => 'input', :attributes => { :name => "block[address]", :value => 'feed address' }
    assert_tag :tag => 'select', :attributes => { :name => "block[limit]" }
  end

  should 'be able to save FeedReaderBlock configurations' do
    @box1.blocks << FeedReaderBlock.new(:address => 'feed address')
    holder.blocks(true)
    block = @box1.blocks.find_by(type: FeedReaderBlock)

    post :save, :profile => 'designtestuser', :id => block.id, :block => {:address => 'new feed address', :limit => '20'}

    block.reload

    assert_equal 'new feed address', block.address
    assert_equal 20, block.limit
  end

  should 'require login' do
    logout
    get :index, :profile => profile.identifier
    assert_redirected_to :controller => 'account', :action => 'login'
  end

  should 'not show sideboxes when render access denied' do
    another_profile = create_user('bobmarley').person
    get :index, :profile => another_profile.identifier
    assert_tag :tag => 'div', :attributes => {:class => 'no-boxes'}
    assert_tag :tag => 'div', :attributes => {:id => 'access-denied'}
  end

  should 'the person blocks are all available' do
    profile = mock
    profile.stubs(:has_members?).returns(false)
    profile.stubs(:person?).returns(true)
    profile.stubs(:community?).returns(true)
    profile.stubs(:enterprise?).returns(false)
    profile.stubs(:has_blog?).returns(false)
    profile.stubs(:is_admin?).with(anything).returns(false)
    environment = mock
    profile.stubs(:environment).returns(environment)
    environment.stubs(:enabled?).returns(false)
    @controller.stubs(:profile).returns(profile)
    @controller.stubs(:user).returns(profile)
    Noosfero::Plugin::Manager.any_instance.stubs(:enabled_plugins).returns([])
    assert_equal PERSON_BLOCKS, @controller.available_blocks
  end

  should 'the person with blog blocks are all available' do
    profile = mock
    profile.stubs(:has_members?).returns(false)
    profile.stubs(:person?).returns(true)
    profile.stubs(:community?).returns(true)
    profile.stubs(:enterprise?).returns(false)
    profile.stubs(:has_blog?).returns(true)
    profile.stubs(:is_admin?).with(anything).returns(false)
    environment = mock
    profile.stubs(:environment).returns(environment)
    environment.stubs(:enabled?).returns(false)
    @controller.stubs(:profile).returns(profile)
    @controller.stubs(:user).returns(profile)
    Noosfero::Plugin::Manager.any_instance.stubs(:enabled_plugins).returns([])
    assert_equal [], @controller.available_blocks - PERSON_BLOCKS_WITH_BLOG
  end

  should 'the enterprise blocks are all available' do
    profile = mock
    profile.stubs(:has_members?).returns(false)
    profile.stubs(:person?).returns(false)
    profile.stubs(:community?).returns(true)
    profile.stubs(:enterprise?).returns(true)
    profile.stubs(:has_blog?).returns(false)
    profile.stubs(:is_admin?).with(anything).returns(false)
    environment = mock
    profile.stubs(:environment).returns(environment)
    environment.stubs(:enabled?).returns(true)
    environment.stubs(:enabled?).with('products_for_enterprises').returns(false)
    @controller.stubs(:profile).returns(profile)
    @controller.stubs(:user).returns(profile)
    Noosfero::Plugin::Manager.any_instance.stubs(:enabled_plugins).returns([])
    assert_equal [], @controller.available_blocks - ENTERPRISE_BLOCKS
  end

  should 'the enterprise with products for enterprise enable blocks are all available' do
    profile = mock
    profile.stubs(:has_members?).returns(false)
    profile.stubs(:person?).returns(false)
    profile.stubs(:community?).returns(true)
    profile.stubs(:enterprise?).returns(true)
    profile.stubs(:has_blog?).returns(false)
    profile.stubs(:is_admin?).with(anything).returns(false)
    environment = mock
    profile.stubs(:environment).returns(environment)
    environment.stubs(:enabled?).returns(true)
    @controller.stubs(:profile).returns(profile)
    @controller.stubs(:user).returns(profile)
    Noosfero::Plugin::Manager.any_instance.stubs(:enabled_plugins).returns([])
    assert_equal [], @controller.available_blocks - ENTERPRISE_BLOCKS_WITH_PRODUCTS_ENABLE
  end

  should 'allow admins to add RawHTMLBlock' do
    profile.stubs(:is_admin?).returns(true)
    @controller.stubs(:user).returns(profile)
    get :index, :profile => 'designtestuser'
    assert_tag :tag => 'div', :attributes => { 'data-block-type' => 'RawHTMLBlock' }
  end

  should 'not allow normal users to add RawHTMLBlock' do
    profile.stubs(:is_admin?).returns(false)
    @controller.stubs(:user).returns(profile)
    get :index, :profile => 'designtestuser'
    assert_no_tag :tag => 'div', :attributes => { 'data-block-type' => 'RawHTMLBlock' }
  end

  should 'editing article block displays right selected article' do
    selected_article = fast_create(Article, :profile_id => profile.id)
    ArticleBlock.any_instance.stubs(:article).returns(selected_article)
    get :edit, :profile => 'designtestuser', :id => @b1.id
    assert_tag :tag => 'option', :attributes => {:value => selected_article.id, :selected => 'selected'}
  end

  should 'the block plugin add a new block' do
    profile = mock
    profile.stubs(:has_members?).returns(false)
    profile.stubs(:person?).returns(true)
    profile.stubs(:community?).returns(true)
    profile.stubs(:enterprise?).returns(false)
    profile.stubs(:has_blog?).returns(false)
    profile.stubs(:is_admin?).with(anything).returns(false)
    environment = mock
    profile.stubs(:environment).returns(environment)
    environment.stubs(:enabled?).returns(false)
    @controller.stubs(:profile).returns(profile)
    @controller.stubs(:user).returns(profile)

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

  should 'a person block plugin add new blocks for person profile' do
    profile = mock
    profile.stubs(:has_members?).returns(false)
    profile.stubs(:person?).returns(true)
    profile.stubs(:community?).returns(false)
    profile.stubs(:enterprise?).returns(false)
    profile.stubs(:has_blog?).returns(false)
    profile.stubs(:is_admin?).with(anything).returns(false)
    environment = mock
    profile.stubs(:environment).returns(environment)
    environment.stubs(:enabled?).returns(false)
    @controller.stubs(:profile).returns(profile)
    @controller.stubs(:user).returns(profile)

    class CustomBlock1 < Block; end;

    class TestBlockPlugin < Noosfero::Plugin
      def self.extra_blocks
        {
          CustomBlock1 => {:type => Person},
        }
      end
    end

    Noosfero::Plugin::Manager.any_instance.stubs(:enabled_plugins).returns([TestBlockPlugin.new])
    assert @controller.available_blocks.include?(CustomBlock1)
  end

  should 'a community block plugin add new blocks for community profile' do
    profile = mock
    profile.stubs(:has_members?).returns(false)
    profile.stubs(:person?).returns(false)
    profile.stubs(:community?).returns(true)
    profile.stubs(:enterprise?).returns(false)
    profile.stubs(:has_blog?).returns(false)
    profile.stubs(:is_admin?).with(anything).returns(false)
    environment = mock
    profile.stubs(:environment).returns(environment)
    environment.stubs(:enabled?).returns(false)
    @controller.stubs(:profile).returns(profile)
    @controller.stubs(:user).returns(profile)

    class CustomBlock1 < Block; end;

    class TestBlockPlugin < Noosfero::Plugin
      def self.extra_blocks
        {
          CustomBlock1 => {:type => Community},
        }
      end
    end

    Noosfero::Plugin::Manager.any_instance.stubs(:enabled_plugins).returns([TestBlockPlugin.new])
    assert @controller.available_blocks.include?(CustomBlock1)
  end

  should 'a enterprise block plugin add new blocks for enterprise profile' do
    profile = mock
    profile.stubs(:has_members?).returns(false)
    profile.stubs(:person?).returns(false)
    profile.stubs(:community?).returns(false)
    profile.stubs(:enterprise?).returns(true)
    profile.stubs(:has_blog?).returns(false)
    profile.stubs(:is_admin?).with(anything).returns(false)
    environment = mock
    profile.stubs(:environment).returns(environment)
    environment.stubs(:enabled?).returns(false)
    @controller.stubs(:profile).returns(profile)
    @controller.stubs(:user).returns(profile)

    class CustomBlock1 < Block; end;

    class TestBlockPlugin < Noosfero::Plugin
      def self.extra_blocks
        {
          CustomBlock1 => {:type => Enterprise},
        }
      end
    end

    Noosfero::Plugin::Manager.any_instance.stubs(:enabled_plugins).returns([TestBlockPlugin.new])
    assert @controller.available_blocks.include?(CustomBlock1)
  end

  should 'an environment block plugin not add new blocks for enterprise, person or community profiles' do
    profile = mock
    profile.stubs(:has_members?).returns(false)
    profile.stubs(:person?).returns(true)
    profile.stubs(:community?).returns(true)
    profile.stubs(:enterprise?).returns(true)
    profile.stubs(:has_blog?).returns(false)
    profile.stubs(:is_admin?).with(anything).returns(false)
    environment = mock
    profile.stubs(:environment).returns(environment)
    environment.stubs(:enabled?).returns(false)
    @controller.stubs(:profile).returns(profile)
    @controller.stubs(:user).returns(profile)

    class CustomBlock1 < Block; end;

    class TestBlockPlugin < Noosfero::Plugin
      def self.extra_blocks
        {
          CustomBlock1 => {:type => Environment},
        }
      end
    end

    Noosfero::Plugin::Manager.any_instance.stubs(:enabled_plugins).returns([TestBlockPlugin.new])
    assert !@controller.available_blocks.include?(CustomBlock1)
  end

  should 'clone a block' do
    block = create(ProfileImageBlock, :box => profile.boxes.first)
    assert_difference 'ProfileImageBlock.count', 1 do
      post :clone_block, :id => block.id, :profile => profile.identifier
      assert_response :redirect
    end
  end

  test 'should forbid POST to save for uneditable blocks' do
    block = profile.blocks.last
    block.edit_modes = "none"
    block.save!

    post :save, id: block.id, profile: profile.identifier
    assert_response :forbidden
  end

  test 'should forbid POST to move_block for fixed blocks' do
    block = profile.blocks.last
    block.move_modes = "none"
    block.save!

    post :move_block, id: block.id, profile: profile.identifier, target: "end-of-box-#{@box3.id}"
    assert_response :forbidden
  end

  should 'guarantee main block is always visible to everybody' do
    get :edit, :profile => 'designtestuser', :id => @b4.id
    %w[logged not_logged followers].each do |option|
      assert_no_tag :select, :attributes => {:name => 'block[display_user]'},
        :descendant => {:tag => 'option', :attributes => {:value => option}}
    end
  end

  should 'update selected categories in blocks' do
    env = Environment.default
    c1 = env.categories.build(:name => "Test category 1"); c1.save!

    block = profile.blocks.last

    Block.any_instance.expects(:accept_category?).at_least_once.returns true

    xhr :get, :update_categories, :profile => profile.identifier, :id => block.id, :category_id => c1.id

    assert_equal assigns(:current_category), c1
  end

  should 'not fail when a profile has a tag block' do
    a = create(Article, :name => 'my article', :profile_id => holder.id, :tag_list => 'tag')
    @box1.blocks << TagsBlock.new
    get :index, :profile => 'designtestuser'
  end
end
