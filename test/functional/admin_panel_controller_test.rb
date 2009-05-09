require File.dirname(__FILE__) + '/../test_helper'
require 'admin_panel_controller'

# Re-raise errors caught by the controller.
class AdminPanelController; def rescue_action(e) raise e end; end

class AdminPanelControllerTest < Test::Unit::TestCase

  all_fixtures
  def setup
    @controller = AdminPanelController.new
    @request    = ActionController::TestRequest.new
    @request.stubs(:ssl?).returns(true)
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
    current = Environment.create!(:name => 'test environment', :is_default => false)
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

  should 'sanitize message for disabled enterprise with white_list' do
    post :site_info, :environment => { :message_for_disabled_enterprise => "This <strong>is</strong> <script>alert('alow')</script>my new environment" }
    assert_redirected_to :action => 'index'
    assert_equal "This <strong>is</strong> my new environment", Environment.default.message_for_disabled_enterprise
  end

  should 'list templates' do
    get :manage_templates

    assert_kind_of Array, assigns(:person_templates)
    assert_kind_of Array, assigns(:community_templates)
    assert_kind_of Array, assigns(:enterprise_templates)
  end

  should 'display environment template options' do
    e = Environment.default
    @controller.stubs(:environment).returns(e)
    profile_template = Profile.create!(:name =>'template_test', :identifier => 'template_test', :environment => e)
    e.settings[:templates_ids] = [profile_template.id]
    e.save!
    e.stubs(:templates).with('person').returns([profile_template])
    e.stubs(:templates).with('community').returns([profile_template])
    e.stubs(:templates).with('enterprise').returns([profile_template])

    assert_equal [profile_template], e.templates('person')

    get :manage_templates
    ['person_template', 'community_template', 'enterprise_template'].each do |template|
      assert_tag :tag => 'select', :attributes => { :id => "environment_#{template}"}, :descendant => { :tag => 'option', :content => 'template_test'} 
    end
  end

  should 'set template' do
    e = Environment.default
    @controller.stubs(:environment).returns(e)
    profile_template = Enterprise.create!(:name =>'template_test', :identifier => 'template_test')

    post :set_template, :environment => {:enterprise_template => profile_template.id}

    assert_equal profile_template, e.enterprise_template
  end

  should 'not use WYSWYIG if disabled' do
    e = Environment.default; e.disable('wysiwyg_editor_for_environment_home'); e.save!
    get :site_info
    assert_no_tag :tag => "script", :content => /tinyMCE\.init/
  end

  should 'use WYSWYIG if enabled' do
    e = Environment.default; e.enable('wysiwyg_editor_for_environment_home'); e.save!
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
    other_e = Environment.create!(:name => 'other environment')
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
    assert_tag :tag => 'option', :attributes => {:value => local.id}, :content => local.name
    assert_tag :tag => 'option', :attributes => {:value => tech.id}, :content => tech.name
    assert_tag :tag => 'option', :attributes => {:value => politics.id}, :content => politics.name
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
end
