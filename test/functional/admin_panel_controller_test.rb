require_relative "../test_helper"
require 'admin_panel_controller'

class AdminPanelControllerTest < ActionController::TestCase

  all_fixtures
  def setup
    @controller = AdminPanelController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    login_as(create_admin_user(Environment.default))
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

  should 'display form for editing site info' do
    get :site_info
    assert_template 'site_info'
    assert_tag :tag => 'textarea', :attributes => { :name => 'environment[description]'}
    assert_tag :tag => 'textarea', :attributes => { :name => 'environment[terms_of_use]'}
    assert_tag :tag => 'input', :attributes => { :name => 'environment[signup_welcome_text_subject]'}
    assert_tag :tag => 'textarea', :attributes => { :name => 'environment[signup_welcome_text_body]'}
    assert_tag :tag => 'textarea', :attributes => { :name => 'environment[signup_welcome_screen_body]'}
  end

  should 'display form for editing message for disabled enterprise' do
    get :message_for_disabled_enterprise
    assert_template 'message_for_disabled_enterprise'
    assert_tag :tag => 'textarea', :attributes => { :name => 'environment[message_for_disabled_enterprise]'}
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

  should 'save subject and body of signup welcome text' do
    subject = "This is my welcome subject"
    body = "This is my welcome body"
    post :site_info, :environment => { :signup_welcome_text_subject => subject, :signup_welcome_text_body => body }
    assert_redirected_to :action => 'index'

    assert_equal subject, Environment.default.signup_welcome_text[:subject]
    assert_equal body, Environment.default.signup_welcome_text[:body]
    assert !Environment.default.signup_welcome_text.blank?
  end

  should 'not save empty string as signup welcome text' do
    content = ""
    post :site_info, :environment => { :signup_welcome_text_body => content }
    assert_redirected_to :action => 'index'

    assert !Environment.default.has_signup_welcome_text?
  end

  should 'sanitize message for disabled enterprise with white_list' do
    post :site_info, :environment => { :message_for_disabled_enterprise => "This <strong>is</strong> <script>alert('alow')</script>my new environment" }
    assert_redirected_to :action => 'index'
    assert_equal "This <strong>is</strong> alert('alow')my new environment", Environment.default.message_for_disabled_enterprise
  end

  should 'save site article date format option' do
    post :site_info, :environment => { :date_format => "numbers_with_year" }
    assert_redirected_to :action => 'index'

    assert_equal "numbers_with_year", Environment.default.date_format
  end

  should 'dont save site article date format option when a invalid option is passed' do
    post :site_info, :environment => { :date_format => "invalid_format" }

    assert_not_equal "invalid_format", Environment.default.date_format
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
    c = create(Community, :name => 'portal community', :environment => other_e)

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
    post :set_portal_news_amount, :environment => { :news_amount_by_folder => '3', :highlighted_news_amount => '2', :portal_news_amount => '5' }
    assert_redirected_to :action => 'index'

    assert_equal 3, Environment.default.news_amount_by_folder
    assert_equal 2, Environment.default.highlighted_news_amount
    assert_equal 5, Environment.default.portal_news_amount
  end

  should 'display plugins links' do
    class TestAdminPanelLinks1 < Noosfero::Plugin
      def admin_panel_links
        {:title => 'Plugin1 link', :url => 'plugin1.com'}
      end
    end
    class TestAdminPanelLinks2 < Noosfero::Plugin
      def admin_panel_links
        {:title => 'Plugin2 link', :url => 'plugin2.com'}
      end
    end

    Noosfero::Plugin::Manager.any_instance.stubs(:enabled_plugins).returns([TestAdminPanelLinks1.new, TestAdminPanelLinks2.new])

    get :index

    assert_tag :tag => 'a', :content => /Plugin1 link/, :attributes => {:href => /plugin1.com/}
    assert_tag :tag => 'a', :content => /Plugin2 link/, :attributes => {:href => /plugin2.com/}
  end

  should 'save available languages and default language properly' do
    post :site_info, :environment => {:default_language => 'pt', :languages => {'pt' => 'true', 'en' => 'false'}}
    environment = Environment.default

    assert_equal 'pt', environment.default_language
    assert_includes environment.languages, 'pt'
    assert_not_includes environment.languages, 'en'
  end

  should 'save body of signup welcome screen' do
    body = "This is my welcome body"
    post :site_info, :environment => { :signup_welcome_screen_body => body }
    assert_redirected_to :action => 'index'

    assert_equal body, Environment.default.signup_welcome_screen_body
    assert !Environment.default.signup_welcome_screen_body.blank?
  end
end
