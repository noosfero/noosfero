require File.dirname(__FILE__) + '/../test_helper'
require 'admin_panel_controller'

# Re-raise errors caught by the controller.
class AdminPanelController; def rescue_action(e) raise e end; end

class AdminPanelControllerTest < ActionController::TestCase

  all_fixtures
  def setup
    @controller = AdminPanelController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    login_as(create_admin_user(Environment.default))
  end

  def test_local_files_reference
    assert_local_files_reference
  end
  
  def test_valid_xhtml
    assert_valid_xhtml
  end

  should 'manage the correct environment' do
    current = fast_create(Environment, :name => 'test environment', :is_default => false)
    current.domains.create!(:name => 'example.com')
    
    @request.expects(:host).returns('example.com').at_least_once
    get :index
    assert_equal current, assigns(:environment)
  end
  
  should 'link to site_info editing page' do
    get :index
    assert_tag :tag => 'a', :attributes => { :href => '/admin/admin_panel/site_info' }
  end

  should 'link to cateogries editing' do
    get :index
    assert_tag :tag => 'a', :attributes => { :href => '/admin/categories' }
  end

  should 'link to design editor' do
    get :index
    assert_tag :tag => 'a', :attributes => { :href => '/admin/environment_design' }
  end

  should 'link to features editing screen' do
    get :index
    assert_tag :tag => 'a', :attributes => { :href => '/admin/features' }
  end

  should 'link to role editing screen' do
    get :index
    assert_tag :tag => 'a', :attributes => { :href => '/admin/role' }
  end

  should 'link to region validator screen' do
    get :index
    assert_tag :tag => 'a', :attributes => { :href => '/admin/region_validators' }
  end

  should 'link to edit message for disabled enterprise' do
    get :index
    assert_tag :tag => 'a', :attributes => { :href => '/admin/admin_panel/message_for_disabled_enterprise' }
  end

  should 'link to define terms of use' do
    get :index
    assert_tag :tag => 'a', :attributes => { :href => '/admin/admin_panel/terms_of_use' }
  end
 
  should 'display form for editing site info' do
    get :site_info
    assert_template 'site_info'
    assert_tag :tag => 'textarea', :attributes => { :name => 'environment[description]'}
  end

  should 'display form for editing message for disabled enterprise' do
    get :message_for_disabled_enterprise
    assert_template 'message_for_disabled_enterprise'
    assert_tag :tag => 'textarea', :attributes => { :name => 'environment[message_for_disabled_enterprise]'}
  end

  should 'display form for editing terms of use' do
    get :terms_of_use
    assert_template 'terms_of_use'
    assert_tag :tag => 'textarea', :attributes => { :name => 'environment[terms_of_use]'}
  end

  should 'save site description' do
    post :site_info, :environment => { :description => "This is my new environment" }
    assert_redirected_to :action => 'index'

    assert_equal "This is my new environment", Environment.default.description
  end

  should 'save message for disabled enterprise' do
    post :site_info, :environment => { :message_for_disabled_enterprise => "This enterprise is disabled" }
    assert_redirected_to :action => 'index'

    assert_equal "This enterprise is disabled", Environment.default.message_for_disabled_enterprise
  end

  should 'save content of terms of use' do
    content = "This is my term of use"
    post :site_info, :environment => { :terms_of_use => content }
    assert_redirected_to :action => 'index'

    assert_equal content, Environment.default.terms_of_use
    assert Environment.default.has_terms_of_use?
  end

  should 'not save empty string as terms of use' do
    content = ""
    post :site_info, :environment => { :terms_of_use => content }
    assert_redirected_to :action => 'index'

    assert !Environment.default.has_terms_of_use?
  end

  should 'sanitize message for disabled enterprise with white_list' do
    post :site_info, :environment => { :message_for_disabled_enterprise => "This <strong>is</strong> <script>alert('alow')</script>my new environment" }
    assert_redirected_to :action => 'index'
    assert_equal "This <strong>is</strong> my new environment", Environment.default.message_for_disabled_enterprise
  end

  should 'always use WYSIWYG' do
    get :site_info
    assert_tag :tag => "script", :content => /tinyMCE\.init/
  end

  should 'set portal community' do
    e = Environment.default
    @controller.stubs(:environment).returns(e)
    c = Community.create!(:name => 'portal_community')

    post :set_portal_community, :portal_community_identifier => c.identifier

    assert_equal c, e.portal_community
  end

  should 'unset portal community' do
    e = Environment.default
    @controller.stubs(:environment).returns(e)
    c = Community.create!(:name => 'portal_community')

    get :unset_portal_community
    e.reload

    assert_nil e.portal_community
    assert_equal false, e.enabled?('use_portal_community')
  end

  should 'redirect to set_portal_community after unset portal community' do
    e = Environment.default
    @controller.stubs(:environment).returns(e)

    get :unset_portal_community
    assert_redirected_to :action => 'set_portal_community'
  end

  should 'enable portal community' do
    e = Environment.default
    @controller.stubs(:environment).returns(e)
    c = Community.create!(:name => 'portal_community')
    e.portal_community=c
    e.save
    assert_equal false, e.enabled?('use_portal_community')

    get :manage_portal_community, :activate => 1
    e.reload
    assert_equal true, e.enabled?('use_portal_community')
  end

  should 'disable portal community' do
    e = Environment.default
    @controller.stubs(:environment).returns(e)
    c = Community.create!(:name => 'portal_community')
    e.portal_community=c
    e.save
    assert_equal false, e.enabled?('use_portal_community')

    get :manage_portal_community, :activate => 0
    e.reload
    assert_equal false, e.enabled?('use_portal_community')
  end

  should 'redirect to set_portal_community after enable or disable portal community' do
    e = Environment.default
    @controller.stubs(:environment).returns(e)
    get :manage_portal_community
    assert_redirected_to :action => 'set_portal_community'
  end

  should 'change portal_community and list new portal folders as options' do
    env = Environment.default
    old = Community.create!(:name => 'old_portal')
    env.portal_community = old
    local = Folder.create!(:profile => old, :name => 'local news')
    tech = Folder.create!(:profile => old, :name => 'tech news')
    env.portal_folders = [local, tech]
    env.save!

    new = Community.create!(:name => 'new_portal')
    politics = Folder.create!(:profile => new, :name => 'politics news')

    post :set_portal_community, :portal_community_identifier => new.identifier
    assert_redirected_to :action => 'set_portal_folders'
    get :set_portal_folders

    assert_tag :tag => 'div', :attributes => {:id => 'available-folders'}, :descendant => {:tag => 'option', :attributes => {:value => politics.id}, :content => politics.name}

    [local, tech].each do |folder|
      assert_no_tag :tag => 'div', :attributes => {:id => 'available-folders'}, :descendant => {:tag => 'option', :attributes => {:value => folder.id}, :content => folder.name}
    end

  end


  should 'redirect to set portal folders' do
    e = Environment.default
    @controller.stubs(:environment).returns(e)
    c = Community.create!(:name => 'portal_community')

    post :set_portal_community, :portal_community_identifier => c.identifier

    assert_response :redirect
    assert_redirected_to :action => 'set_portal_folders'
  end

  should 'not have a portal community from other environment' do
    e = Environment.default
    @controller.stubs(:environment).returns(e)
    other_e = fast_create(Environment, :name => 'other environment')
    c = Community.create!(:name => 'portal community', :environment => other_e)

    post :set_portal_community, :portal_community_identifier => c.identifier
    e.reload

    assert_not_equal c, e.portal_community
  end

  should 'give error when portal community is not given' do
    post :set_portal_community, :portal_community_identifier => 'no_community'
    assert_response :success
    assert_template 'set_portal_community'
  end

  should 'give portal_community folders as option for portal folders' do
    env = Environment.default
    c = Community.create!(:name => 'portal')
    env.portal_community = c
    local = Folder.create!(:profile => c, :name => 'local news')
    tech = Folder.create!(:profile => c, :name => 'tech news')
    politics = Folder.create!(:profile => c, :name => 'politics news')
    env.save!

    get :set_portal_folders
    [local, tech, politics].each do |folder|
      assert_tag :tag => 'div', :attributes => {:id => 'available-folders'}, :descendant => {:tag => 'option', :attributes => {:value => folder.id}, :content => folder.name}
    end
  end

  should 'not display not portal folders on portal-folders' do
    env = Environment.default
    c = Community.create!(:name => 'portal')
    env.portal_community = c
    local = Folder.create!(:profile => c, :name => 'local news')
    tech = Folder.create!(:profile => c, :name => 'tech news')
    politics = Folder.create!(:profile => c, :name => 'politics news')
    env.save!

    get :set_portal_folders
    [local, tech, politics].each do |folder|
      assert_no_tag :tag => 'div', :attributes => {:id => 'portal-folders'}, :descendant => {:tag => 'option', :attributes => {:value => folder.id}, :content => folder.name}
    end
  end

  should 'list portal folders for removal' do
    env = Environment.default
    c = Community.create!(:name => 'portal')
    env.portal_community = c
    local = Folder.create!(:profile => c, :name => 'local news')
    tech = Folder.create!(:profile => c, :name => 'tech news')
    politics = Folder.create!(:profile => c, :name => 'politics news')
    env.save!
    env.portal_folders = [local, tech]
    env.save!

    get :set_portal_folders
    [local, tech].each do |folder|
      assert_tag :tag => 'div', :attributes => {:id => 'portal-folders'}, :descendant => {:tag => 'option', :attributes => {:value => folder.id}, :content => folder.name}
    end

    assert_no_tag :tag => 'div', :attributes => {:id => 'portal-folders'}, :descendant => {:tag => 'option', :attributes => {:value => politics.id}, :content => politics.name}
  end

  should 'save a list of folders as portal folders for the environment' do
    env = Environment.default
    @controller.stubs(:environment).returns(env)
    c = Community.create!(:name => 'portal')
    env.portal_community = c
    local = Folder.create!(:profile => c, :name => 'local news')
    discarded = Folder.create!(:profile => c, :name => 'discarded news')
    tech = Folder.create!(:profile => c, :name => 'tech news')
    politics = Folder.create!(:profile => c, :name => 'politics news')
    env.save!

    post :set_portal_folders, :folders => [local, politics, tech].map(&:id)

    assert_equal [local, politics, tech].map(&:id), env.portal_folders.map(&:id)
  end

  should 'remove all folders as portal folders for the environment' do
    env = Environment.default
    @controller.stubs(:environment).returns(env)
    c = Community.create!(:name => 'portal')
    env.portal_community = c
    env.save!

    post :set_portal_folders

    assert_equal [], env.portal_folders
  end

  should 'have amount of news on portal' do
    env = Environment.default
    env.news_amount_by_folder = 5
    env.save

    get :set_portal_news_amount
    assert_tag :tag => 'select', :descendant => {:tag => 'option', :attributes => {:value => 5, :selected => 'selected'}}
  end

  should 'save amount of news' do
    post :set_portal_news_amount, :environment => { :news_amount_by_folder => '3' }
    assert_redirected_to :action => 'index'

    assert_equal 3, Environment.default.news_amount_by_folder
  end

  should 'display plugins links' do
    plugin1_link = {:title => 'Plugin1 link', :url => 'plugin1.com'}
    plugin2_link = {:title => 'Plugin2 link', :url => 'plugin2.com'}
    links = [plugin1_link, plugin2_link]
    plugins = mock()
    plugins.stubs(:map).with(:admin_panel_links).returns(links)
    plugins.stubs(:enabled_plugins).returns([])
    plugins.stubs(:map).with(:body_beginning).returns([])
    Noosfero::Plugin::Manager.stubs(:new).returns(plugins)

    get :index

    assert_tag :tag => 'a', :content => /#{plugin1_link[:title]}/, :attributes => {:href => /#{plugin1_link[:url]}/}
    assert_tag :tag => 'a', :content => /#{plugin2_link[:title]}/, :attributes => {:href => /#{plugin2_link[:url]}/}
  end

end
