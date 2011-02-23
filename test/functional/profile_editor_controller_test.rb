require File.dirname(__FILE__) + '/../test_helper'
require 'profile_editor_controller'

# Re-raise errors caught by the controller.
class ProfileEditorController; def rescue_action(e) raise e end; end

class ProfileEditorControllerTest < ActionController::TestCase
  all_fixtures
  
  def setup
    @controller = ProfileEditorController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    @profile = create_user('default_user').person
    Environment.default.affiliate(@profile, [Environment::Roles.admin(Environment.default.id)] + Profile::Roles.all_roles(Environment.default.id))
    login_as('default_user')
  end
  attr_reader :profile

  def test_local_files_reference
    assert_local_files_reference :get, :index, :profile => profile.identifier
  end
  
  def test_valid_xhtml
    assert_valid_xhtml
  end
  
  def test_index
    get :index, :profile => profile.identifier
    assert_template 'index'
    assert_response :success
    assert_not_nil assigns(:profile)
  end

  def test_should_present_pending_tasks_in_index
    ze = Profile['ze'] # a fixture >:-(
    @controller.expects(:profile).returns(ze).at_least_once
    tasks = mock
    pending = []
    pending.expects(:select).returns(pending)
    pending.expects(:empty?).returns(false) # force the display of the pending tasks list
    ze.expects(:all_pending_tasks).returns(pending)
    get :index, :profile => ze.identifier
    assert_same pending, assigns(:pending_tasks)
    assert_tag :tag => 'div', :attributes => { :class => 'pending-tasks' }, :descendant => { :tag => 'a', :attributes =>  { :href => '/myprofile/ze/tasks' } }
  end

  def test_edit_person_info
    get :edit, :profile => profile.identifier
    assert_response :success
    assert_template 'edit'
  end

  should 'saving profile info' do
    person = profile 
    post :edit, :profile => profile.identifier, :profile_data => { 'name' => 'new person', 'contact_information' => 'new contact information', 'address' => 'new address', 'sex' => 'female' }
    assert_redirected_to :action => 'index'
    person = Person.find(person.id)
    assert_equal 'new person', person.name
    assert_equal 'new contact information', person.contact_information
    assert_equal 'new address', person.address
    assert_equal 'female', person.sex
  end

  should 'not permmit if not logged' do
    logout
    get :index, :profile => profile.identifier
    assert_response 302
  end

  should 'display categories to choose to associate profile' do
    cat1 = Environment.default.categories.build(:display_in_menu => true, :name => 'top category'); cat1.save!
    cat2 = Environment.default.categories.build(:display_in_menu => true, :name => 'sub category', :parent => cat1); cat2.save!
    person = profile
    get :edit, :profile => profile.identifier
    assert_response :success
    assert_template 'edit'
    assert_tag :tag => 'input', :attributes => {:name => 'profile_data[category_ids][]', :value => cat2.id}
  end

  should 'save categorization of profile' do
    cat1 = Environment.default.categories.build(:name => 'top category'); cat1.save!
    cat2 = Environment.default.categories.build(:name => 'sub category', :parent => cat1); cat2.save!
    person = profile
    post :edit, :profile => profile.identifier, :profile_data => {:category_ids => [cat2.id]}
    assert_response :redirect
    assert_redirected_to :action => 'index'
    assert_includes person.categories, cat2
  end

  should 'filter html from person name' do
    name = "name <strong id='name_html_test'>with</strong> html"
    post :edit, :profile => profile.identifier, :profile_data => { :name => name }
    assert_sanitized assigns(:profile).name
  end

  should 'filter html from organization fields' do
    org = fast_create(Organization)
    contact = "name <strong id='name_html_test'>with</strong> html"
    acronym = "name <strong id='name_html_test'>with</strong> html"
    legal_form = "name <strong id='name_html_test'>with</strong> html"
    economic_activity = "name <strong id='name_html_test'>with</strong> html"
    management_information = "name <strong id='name_html_test'>with</strong> html"

    post :edit, :profile => org.identifier, :profile_data => { :name => name, :contact_person => contact, :acronym => acronym, :legal_form => legal_form, :economic_activity => economic_activity, :management_information =>  management_information}

    assert_sanitized assigns(:profile).contact_person
    assert_sanitized assigns(:profile).acronym
    assert_sanitized assigns(:profile).legal_form
    assert_sanitized assigns(:profile).economic_activity
    assert_sanitized assigns(:profile).management_information
  end

  should 'saving profile organization_info' do
    org = fast_create(Organization)
    post :edit, :profile => org.identifier, :profile_data => { :contact_person => 'contact person' }
    assert_equal 'contact person', Organization.find(org.id).contact_person
  end

  should 'show contact_phone field on edit enterprise' do
    org = fast_create(Enterprise)
    Enterprise.any_instance.expects(:active_fields).returns(['contact_phone']).at_least_once
    get :edit, :profile => org.identifier
    assert_tag :tag => 'input', :attributes => { :name => 'profile_data[contact_phone]' }
  end

  should 'save community description' do
    org = fast_create(Community)
    post :edit, :profile => org.identifier, :profile_data => { :description => 'my description' }
    assert_equal 'my description', Organization.find(org.id).description
  end

  should 'show community description' do
    org = fast_create(Community)
    Community.any_instance.expects(:active_fields).returns(['description']).at_least_once
    get :edit, :profile => org.identifier
    assert_tag :tag => 'textarea', :attributes => { :name => 'profile_data[description]' }
  end

  should 'not show enterprise description' do
    org = fast_create(Enterprise)
    get :edit, :profile => org.identifier
    assert_no_tag :tag => 'textarea', :attributes => { :name => 'profile_data[description]' }
  end

  should 'save organization contact_person' do
    org = fast_create(Organization)
    post :edit, :profile => org.identifier, :profile_data => { :contact_person => 'my contact' }
    assert_equal 'my contact', Organization.find(org.id).contact_person
  end

  should 'save enterprise contact_person' do
    org = fast_create(Enterprise)
    post :edit, :profile => org.identifier, :profile_data => { :contact_person => 'my contact' }
    assert_equal 'my contact', Enterprise.find(org.id).contact_person
  end

  should 'show field values on edit community info' do
    Community.any_instance.expects(:active_fields).returns(['contact_person']).at_least_once
    org = fast_create(Community)
    org.contact_person = 'my contact'
    org.save!
    get :edit, :profile => org.identifier
    assert_tag :tag => 'input', :attributes => { :name => 'profile_data[contact_person]', :value => 'my contact' }
  end

  should 'show field values on edit enterprise info' do
    Enterprise.any_instance.expects(:active_fields).returns(['contact_person']).at_least_once
    org = fast_create(Enterprise)
    org.contact_person = 'my contact'
    org.save!
    get :edit, :profile => org.identifier
    assert_tag :tag => 'input', :attributes => { :name => 'profile_data[contact_person]', :value => 'my contact' }
  end

  should 'display profile publication option in edit profile screen' do
    get :edit, :profile => profile.identifier
    assert_tag :tag => 'input', :attributes => { :type => 'radio', :checked => 'checked', :name => 'profile_data[public_profile]', :value => 'true' }
    assert_tag :tag => 'input', :attributes => { :type => 'radio', :name => 'profile_data[public_profile]', :value => 'false' }
  end

  should 'display properly that the profile is non-public' do
    profile.update_attributes!(:public_profile => false)
    get :edit, :profile => profile.identifier
    assert_tag :tag => 'input', :attributes => { :type => 'radio', :checked => 'checked', :name => 'profile_data[public_profile]', :value => 'false' }
    assert_tag :tag => 'input', :attributes => { :type => 'radio', :name => 'profile_data[public_profile]', :value => 'true' }
  end

  should 'save profile publication option set to true' do
    post :edit, :profile => profile.identifier, :profile_data => { :public_profile => 'true' }
    assert_equal true, profile.public_profile
  end

  should 'save profile publication option set to false' do
    post :edit, :profile => profile.identifier, :profile_data => { :public_profile => 'false' }
    profile = Person.find(@profile.id)
    assert_equal false, profile.public_profile
  end

  should 'show error messages for invalid foundation_year' do
    org = fast_create(Community)
    post :edit, :profile => org.identifier, :profile_data => { :foundation_year => 'aaa' }
    assert_tag :tag => 'div', :attributes => { :id => 'errorExplanation' }
  end

  should 'edit enterprise' do
    ent = fast_create(Enterprise)
    get :edit, :profile => ent.identifier
    assert_response :success
  end

  should 'back when update community info fail' do
    org = fast_create(Community)
    Community.any_instance.stubs(:update_attributes!).returns(false)
    post :edit, :profile => org.identifier
    assert_template 'edit'
  end

  should 'back when update enterprise info fail' do
    org = fast_create(Enterprise)
    Enterprise.any_instance.stubs(:update_attributes!).returns(false)
    post :edit, :profile => org.identifier
    assert_template 'edit'
  end

  should 'show edit profile button' do
    get :index, :profile => profile.identifier
    assert_tag :tag => 'a', :attributes => { :href => "/myprofile/#{profile.identifier}/profile_editor/edit" }
  end

  should 'show image field on edit profile' do
    get :edit, :profile => profile.identifier
    assert_tag :tag => 'input', :attributes => { :name => 'profile_data[image_builder][uploaded_data]' }
  end

  should 'show categories links on edit profile' do
    cat1 = Environment.default.categories.create!(:display_in_menu => true, :name => 'top category')
    cat2 = Environment.default.categories.create!(:display_in_menu => true, :name => 'sub category', :parent => cat1)
    person = create_user('testuser').person
    get :edit, :profile => 'testuser'
    assert_tag :tag => 'input', :attributes => { :type => 'checkbox', :name => 'profile_data[category_ids][]', :value => cat2.id}
  end

  should 'render edit template' do
    get :edit, :profile => profile.identifier
    assert_template 'edit'
  end

  should 'render person partial' do
    person = profile
    Person.any_instance.expects(:active_fields).returns(['contact_phone', 'address']).at_least_once
    get :edit, :profile => person.identifier
    person.active_fields.each do |field|
      assert_tag :tag => 'input', :attributes => { :name => "profile_data[#{field}]" }
    end
  end

  should 'display only active person fields' do
    Person.any_instance.expects(:active_fields).returns(['cell_phone']).at_least_once

    get :edit, :profile => profile.identifier

    assert_tag :tag => 'input', :attributes => { :name => "profile_data[cell_phone]" }
    assert_no_tag :tag => 'input', :attributes => { :name => "profile_data[comercial_phone]" }
  end

  should 'be able to upload an image' do
    assert_nil profile.image
    post :edit, :profile => profile.identifier, :profile_data => { :image_builder => { :uploaded_data => fixture_file_upload('/files/rails.png', 'image/png') } }
    assert_not_nil assigns(:profile).image
  end

  should 'display closed attribute for communities when it is set' do
    org = fast_create(Community)
    org.closed = true
    org.save!

    get :edit, :profile => org.identifier

    assert_tag :tag => 'input', :attributes => { :type => 'radio', :name => 'profile_data[closed]', :value => 'true', :checked => 'checked' }
    assert_no_tag :tag => 'input', :attributes => { :type => 'radio', :name => 'profile_data[closed]', :value => 'false', :checked =>  'checked' }
  end

  should 'display closed attribute for communities when it is set to false' do
    org = fast_create(Community)

    [false, nil].each do |value|
      org.closed = value
      org.save!
      get :edit, :profile => org.identifier
      assert_no_tag :tag => 'input', :attributes => { :type => 'radio', :name => 'profile_data[closed]', :value => 'true', :checked => 'checked' }
      assert_tag :tag => 'input', :attributes => { :type => 'radio', :name => 'profile_data[closed]', :value => 'false', :checked => 'checked' }
    end
  end

  should 'set closed attribute correctly' do
    org = fast_create(Organization)
    org.closed = false
    org.save!

    post :edit, :profile => org.identifier, :profile_data => { :closed => 'true' }
    org.reload
    assert org.closed
  end

  should 'unset closed attribute correctly' do
    org = fast_create(Organization)
    org.closed = true
    org.save!

    post :edit, :profile => org.identifier, :profile_data => { :closed => 'false' }
    org.reload
    assert !org.closed
  end

  should 'not display option to close when it is enterprise' do
    org = fast_create(Enterprise)
    get :edit, :profile => org.identifier

    assert_no_tag :tag => 'input', :attributes => { :type => 'radio', :name => 'profile_data[closed]', :value => 'true' }
    assert_no_tag :tag => 'input', :attributes => { :type => 'radio', :name => 'profile_data[closed]', :value => 'false' }
  end

  should 'display option to close when it is community' do
    org = fast_create(Community)
    get :edit, :profile => org.identifier

    assert_tag :tag => 'input', :attributes => { :type => 'radio', :name => 'profile_data[closed]', :value => 'true' }
    assert_tag :tag => 'input', :attributes => { :type => 'radio', :name => 'profile_data[closed]', :value => 'false' }
  end

  should 'display manage members options if has permission' do
    profile = Profile['ze']
    community = fast_create(Community)
    @controller.stubs(:user).returns(profile)
    @controller.stubs(:profile).returns(community)
    profile.stubs(:has_permission?).returns(true)
    get :index, :profile => community.identifier
    assert_tag :tag => 'a', :content => 'Manage Members'
  end

  should 'not display manage members options if has no permission' do
    profile = Profile['ze']
    community = fast_create(Community)
    @controller.stubs(:user).returns(profile)
    @controller.stubs(:profile).returns(community)
    profile.stubs(:has_permission?).returns(false)
    get :index, :profile => community.identifier
    assert_no_tag :tag => 'a', :content => 'Manage Members'
  end

  should 'render enterprise partial' do
    ent = fast_create(Enterprise)
    Enterprise.any_instance.expects(:active_fields).returns(['contact_phone', 'contact_person', 'contact_email']).at_least_once
    get :edit, :profile => ent.identifier
    ent.active_fields.each do |field|
      assert_tag :tag => 'input', :attributes => { :name => "profile_data[#{field}]" }
    end
  end

  should 'render community partial' do
    community = fast_create(Community)
    Community.any_instance.expects(:active_fields).returns(['contact_person', 'language']).at_least_once
    get :edit, :profile => community.identifier
    community.active_fields.each do |field|
      assert_tag :tag => 'input', :attributes => { :name => "profile_data[#{field}]" }
    end
  end

  should 'show task if user has permission' do
    user1 = profile
    user2 = create_user('usertwo').person
    AddFriend.create!(:person => user1, :friend => user2)
    @controller.stubs(:user).returns(user2)
    user2.stubs(:has_permission?).with('edit_profile', anything).returns(true)
    user2.expects(:has_permission?).with(:manage_friends, anything).returns(true)
    login_as('usertwo')
    get :index, :profile => 'usertwo'
    assert_tag :tag => 'div', :attributes => { :class => 'pending-tasks' }
  end

  should 'not show task if user has no permission' do
    user1 = profile
    user2 = create_user('usertwo').person
    task = AddFriend.create!(:person => user1, :friend => user2)
    @controller.stubs(:user).returns(user2)
    user2.stubs(:has_permission?).with('edit_profile', anything).returns(true)
    user2.expects(:has_permission?).with(:manage_friends, anything).returns(false)
    login_as('usertwo')
    get :index, :profile => 'usertwo'
    assert_no_tag :tag => 'div', :attributes => { :class => 'pending-tasks' }
  end

  should 'show favorite enterprises button for person' do
    get :index, :profile => profile.identifier
    assert_tag :tag => 'a', :content => 'Favorite Enterprises'
  end

  should 'not show favorite enterprises button for organization' do
    org = fast_create(Organization)
    get :index, :profile => org.identifier
    assert_no_tag :tag => 'a', :content => 'Favorite Enterprises'
  end

  should 'link to mailconf' do
    MailConf.expects(:enabled?).returns(true).at_least_once
    get :index, :profile => profile.identifier
    assert_tag :tag => 'a', :attributes => { :href => "/myprofile/#{profile.identifier}/mailconf" }
  end

  should 'not link to mailconf for organizations' do
    MailConf.stubs(:enabled?).returns(true)
    org = fast_create(Organization)
    get :index, :profile => org.identifier
    assert_no_tag :tag => 'a', :attributes => { :href => "/myprofile/#{org.identifier}/mailconf" }
  end

  should 'not link to mailconf if mail not enabled' do
    MailConf.expects(:enabled?).returns(false).at_least_once
    get :index, :profile => profile.identifier
    assert_no_tag :tag => 'a', :attributes => { :href => "/myprofile/#{profile.identifier}/mailconf" }
  end

  should 'link to enable enterprise' do
    ent = fast_create(Enterprise, :enabled => false)
    get :index, :profile => ent.identifier
    assert_tag :tag => 'a', :attributes => { :href => "/myprofile/#{ent.identifier}/profile_editor/enable" }
  end
  
  should 'link to disable enterprise' do
    ent = fast_create(Enterprise, :enabled => true)
    get :index, :profile => ent.identifier
    assert_tag :tag => 'a', :attributes => { :href => "/myprofile/#{ent.identifier}/profile_editor/disable" }
  end

  should 'not link to enable/disable for non enterprises' do
    ent = fast_create(Organization, :enabled => true)
    get :index, :profile => ent.identifier
    assert_no_tag :tag => 'a', :attributes => { :href => "/myprofile/#{ent.identifier}/profile_editor/disable" }
  end

  should 'request enable enterprise confirmation' do
    ent = fast_create(Enterprise, :enabled => false)
    get :enable, :profile => ent.identifier
    assert_tag :tag => 'form', :attributes => { :action => "/myprofile/#{ent.identifier}/profile_editor/enable", :method => 'post' }
  end

  should 'enable enterprise after confirmation' do
    ent = fast_create(Enterprise, :enabled => false)
    post :enable, :profile => ent.identifier, :confirmation => 1
    assert assigns(:to_enable).enabled?
  end

  should 'not enable enterprise without confirmation' do
    ent = fast_create(Enterprise, :enabled => false)
    post :enable, :profile => ent.identifier
    assert !assigns(:to_enable).enabled?
  end

  should 'disable enterprise after confirmation' do
    ent = fast_create(Enterprise, :enabled => true)
    post :disable, :profile => ent.identifier, :confirmation => 1
    assert !assigns(:to_disable).enabled?
  end

  should 'not disable enterprise without confirmation' do
    ent = fast_create(Enterprise, :enabled => true)
    post :disable, :profile => ent.identifier
    assert assigns(:to_disable).enabled?
  end

  should 'update categories' do
    env = Environment.default
    top = env.categories.create!(:display_in_menu => true, :name => 'Top-Level category')
    c1  = env.categories.create!(:display_in_menu => true, :name => "Test category 1", :parent_id => top.id)
    c2  = env.categories.create!(:display_in_menu => true, :name => "Test category 2", :parent_id => top.id)
    get :update_categories, :profile => profile.identifier, :category_id => top.id
    assert_template 'shared/_select_categories'
    assert_equal top, assigns(:current_category)
    assert_equal [c1, c2], assigns(:categories)
  end

  should 'display manage my groups button for person' do
    get :index, :profile => profile.identifier
    assert_tag :tag => 'a', :content => 'Manage my groups'
  end

  should 'display footer edit screen' do

    person = profile
    person.custom_header = 'my custom header'
    person.custom_footer = 'my custom footer'
    person.save!

    get :header_footer, :profile => profile.identifier
    assert_tag :tag => 'textarea', :content => 'my custom header'
    assert_tag :tag => 'textarea', :content => 'my custom footer'
  end

  should 'save footer and header' do
    person = profile
    post :header_footer, :profile => profile.identifier, :custom_header => 'new header', :custom_footer => 'new footer'
    person = Person.find(person.id)
    assert_equal 'new header', person.custom_header
    assert_equal 'new footer', person.custom_footer
  end

  should 'save header and footer even if model is invalid' do
    person = profile
    person.sex = nil; person.save!
    person.environment.custom_person_fields = {'sex' => {'required' => 'true', 'active' => 'true'} }; person.environment.save!

    post :header_footer, :profile => profile.identifier, :custom_header => 'new header', :custom_footer => 'new footer'
    person = Person.find(person.id)
    assert_equal 'new header', person.custom_header
    assert_equal 'new footer', person.custom_footer
  end

  should 'go back to editor after saving header/footer' do
    post :header_footer, :profile => profile.identifier, :custom_header => 'new header', :custom_footer => 'new footer'
    assert_redirected_to :action => 'index'
  end

  should 'point to header/footer editing in control panel' do
    get :index, :profile => profile.identifier
    assert_tag :tag => 'a', :attributes => { :href => "/myprofile/#{profile.identifier}/profile_editor/header_footer" }
  end

  should 'not display header/footer button to enterprises if the environment disabled it' do
    env = Environment.default
    env.enable('disable_header_and_footer')
    env.save!

    enterprise = fast_create(Enterprise)

    u = create_user_with_permission('test_user', 'edit_profile', enterprise)
    login_as('test_user')

    get :index, :profile => enterprise.identifier
    assert_no_tag :tag => 'a', :attributes => { :href => "/myprofile/#{enterprise.identifier}/profile_editor/header_footer" }
  end

  should 'display header/footer button to enterprises if the environment disabled it but user is admin' do
    env = Environment.default
    env.enable('disable_header_and_footer')
    env.save!

    enterprise = fast_create(Enterprise)

    Person.any_instance.expects(:is_admin?).returns(true).at_least_once

    get :index, :profile => enterprise.identifier
    assert_tag :tag => 'a', :attributes => { :href => "/myprofile/#{enterprise.identifier}/profile_editor/header_footer" }
  end

  should 'not list the manage products button if the environment disabled it' do
    env = Environment.default
    env.enable('disable_products_for_enterprises')
    env.save!
    ent = fast_create(Enterprise)

    u = create_user_with_permission('test_user', 'edit_profile', ent)
    login_as('test_user')

    get :index, :profile => ent.identifier

    assert_no_tag :tag => 'span', :content => 'Manage Products and Services'
  end

  should 'display categories if environment disable_categories disabled' do
    Environment.any_instance.stubs(:enabled?).with(anything).returns(false)
    get :edit, :profile => profile.identifier
    assert_tag :tag => 'div', :descendant => { :tag => 'h2', :content => 'Select the categories of your interest' }
  end

  should 'not display categories if environment disable_categories enabled' do
    Environment.any_instance.stubs(:enabled?).with(anything).returns(true)
    get :edit, :profile => profile.identifier
    assert_no_tag :tag => 'div', :descendant => { :tag => 'h2', :content => 'Select the categories of your interest' }
  end

  should 'show a e-mail field in profile editor' do
    get :edit, :profile => profile.identifier

    assert_tag :tag => 'input',
               :attributes => { :name=>'profile_data[email]', :value => profile.email }
  end

  should 'display enable contact us for enterprise' do
    org = fast_create(Enterprise)
    get :edit, :profile => org.identifier
    assert_tag :tag => 'input', :attributes => {:name => 'profile_data[enable_contact_us]', :type => 'checkbox'}
  end

  should 'display link to CMS' do
    get :index, :profile => profile.identifier
    assert_tag :tag => 'a', :attributes => { :href => '/myprofile/default_user/cms' }
  end

  should 'not display link to CMS if disabled' do
    env = Environment.default
    env.enable('disable_cms')
    env.save!
    get :index, :profile => profile.identifier

    assert_no_tag :tag => 'a', :attributes => { :href => '/myprofile/default_user/cms' }
  end

  should 'offer to create blog in control panel' do
    get :index, :profile => profile.identifier
    assert_tag :tag => 'a', :attributes => { :href => "/myprofile/default_user/cms/new?type=Blog" }
  end

  should 'offer to config blog in control panel' do
    profile.articles << Blog.new(:name => 'My blog', :profile => profile)
    get :index, :profile => profile.identifier
    assert_tag :tag => 'a', :attributes => { :href => "/myprofile/#{profile.identifier}/cms/edit/#{profile.blog.id}" }
  end

  should 'not show select preferred domain if not enabled in environment' do
    profile.environment.custom_person_fields = {}; profile.environment.save!

    get :edit, :profile => profile.identifier
    assert_no_tag :tag => 'select', :attributes => { :name => 'profile_data[preferred_domain_id]' }
  end

  should 'be able to choose preferred domain' do
    profile.environment.custom_person_fields = {'preferred_domain' => {'required' => 'true', 'active' => 'true'} }; profile.environment.save!

    profile.domains << Domain.new(:name => 'myowndomain.net')
    profile.environment.domains << Domain.new(:name => 'myenv.net')

    get :edit, :profile => profile.identifier
    assert_tag :tag => 'select', :attributes => { :name => 'profile_data[preferred_domain_id]' }, :descendant => { :tag => "option", :content => 'myowndomain.net' }
    assert_tag :tag => 'select', :attributes => { :name => 'profile_data[preferred_domain_id]' }, :descendant => { :tag => "option", :content => 'myenv.net' }

    post :edit, :profile => profile.identifier, :profile_data => { :preferred_domain_id => profile.domains.first.id.to_s }

    assert_equal 'myowndomain.net', Profile.find(profile.id).preferred_domain.name
  end

  should 'be able to set no preferred domain at all' do
    profile.environment.custom_person_fields = {'preferred_domain' => {'required' => 'true', 'active' => 'true'} }; profile.environment.save!

    profile.domains << Domain.new(:name => 'myowndomain.net')
    profile.environment.domains << Domain.new(:name => 'myenv.net')

    get :edit, :profile => profile.identifier
    assert_tag :tag => "select", :attributes => { :name => 'profile_data[preferred_domain_id]'}, :descendant => { :tag => 'option', :content => '&lt;Select domain&gt;', :attributes => { :value => '' } }

    post :edit, :profile => profile.identifier, :profile_data => { :preferred_domain_id => '' }
    assert_nil Profile.find(profile.id).preferred_domain
  end

  should 'not be able to upload an image bigger than max size' do
    Image.any_instance.stubs(:size).returns(Image.attachment_options[:max_size] + 1024)
    person = profile
    assert_nil person.image
    post :edit, :profile => person.identifier, :profile_data => { :image_builder => { :uploaded_data => fixture_file_upload('/files/rails.png', 'image/png') } }
    assert_nil person.image
  end

  should 'display error message when image has more than max size' do
    Image.any_instance.stubs(:size).returns(Image.attachment_options[:max_size] + 1024)
    post :edit, :profile => profile.identifier, :profile_data => { :image_builder => { :uploaded_data => fixture_file_upload('/files/rails.png', 'image/png') } }
    assert_tag :tag => 'div', :attributes => { :class => 'errorExplanation', :id => 'errorExplanation' }
  end

  should 'not display error message when image has less than max size' do
    Image.any_instance.stubs(:size).returns(Image.attachment_options[:max_size] - 1024)
    post :edit, :profile => profile.identifier, :profile_data => { :image_builder => { :uploaded_data => fixture_file_upload('/files/rails.png', 'image/png') } }
    assert_no_tag :tag => 'div', :attributes => { :class => 'errorExplanation', :id => 'errorExplanation' }
  end

  should 'not redirect when some file has errors' do
    Image.any_instance.stubs(:size).returns(Image.attachment_options[:max_size] + 1024)
    post :edit, :profile => profile.identifier, :profile_data => { :image_builder => { :uploaded_data => fixture_file_upload('/files/rails.png', 'image/png') } }
    assert_response :success
    assert_template 'edit'
  end

  should 'not display form for enterprise activation if disabled in environment' do
    env = Environment.default
    env.disable('enterprise_activation')
    env.save!

    get :index, :profile => profile.identifier
    assert_no_tag :tag => 'div', :attributes => { :id => 'activation_enterprise' }, :descendant => {:tag => 'form', :attributes => {:action => '/account/activation_question'}}
  end

  should 'display form for enterprise activation if enabled on environment' do
    env = Environment.default
    env.enable('enterprise_activation')
    env.save!

    get :index, :profile => profile.identifier
    assert_tag :tag => 'div', :attributes => { :id => 'activation_enterprise' }, :descendant => {:tag => 'form', :attributes => {:action => '/account/activation_question'}}
  end

  should 'not display enterprise activation to enterprises' do
    env = Environment.default
    env.enable('enterprise_activation')
    env.save!

    enterprise = fast_create(Enterprise)
    enterprise.add_admin(profile)

    get :index, :profile => enterprise.identifier
    assert_no_tag :tag => 'div', :attributes => { :id => 'activation_enterprise' }, :descendant => {:tag => 'form', :attributes => {:action => '/account/activation_question'}}
  end

  should 'have url field for identifier when environment allows' do
    c = fast_create(Community)
    env = c.environment
    env.enable('enable_organization_url_change')
    env.save!

    get :edit, :profile => c.identifier
    assert_tag :tag => 'div',
               :attributes => { :class => 'formfield type-text' },
               :content => /https?:\/\/#{c.environment.default_hostname}\//,
               :descendant => {:tag => 'input', :attributes => {:id => 'profile_data_identifier'} }
  end

  should 'not have url field for identifier when environment not allows' do
    c = fast_create(Community)
    env = c.environment
    env.disable('enable_organization_url_change')
    env.save!

    get :edit, :profile => c.identifier
    assert_no_tag :tag => 'div',
               :attributes => { :class => 'formfield type-text' },
               :content => /https?:\/\/#{c.environment.default_hostname}\//,
               :descendant => {:tag => 'input', :attributes => {:id => 'profile_data_identifier'} }
  end

  should 'redirect to new url when is changed' do
    c = fast_create(Community)
    post :edit, :profile => c.identifier, :profile_data => {:identifier => 'new_address'}
    assert_response :redirect
    assert_redirected_to :action => 'index', :profile => 'new_address'
  end

  should 'not crash if identifier is left blank' do
    c = fast_create(Community)
    assert_nothing_raised do
      post :edit, :profile => c.identifier, :profile_data => c.attributes.merge('identifier' => '')
    end
    assert_response :success
  end

  should 'show active fields when edit community' do
    env = Environment.default
    env.custom_community_fields = {
      'contact_email' => {'active' => 'true', 'required' => 'false'},
      'contact_phone' => {'active' => 'true', 'required' => 'false'}
    }
    env.save!
    community = fast_create(Community)

    get :edit, :profile => community.identifier

    community.active_fields.each do |field|
      assert_tag :tag => 'input', :attributes => { :name => "profile_data[#{field}]" }
    end
  end

  should 'not show disabled fields when edit community' do
    env = Environment.default
    env.custom_community_fields = {
      'contact_email' => {'active' => 'false', 'required' => 'false'},
      'contact_phone' => {'active' => 'false', 'required' => 'false'}
    }
    env.save!
    community = fast_create(Community)

    get :edit, :profile => community.identifier

    (Community.fields - community.active_fields).each do |field|
      assert_no_tag :tag => 'input', :attributes => { :name => "profile_data[#{field}]" }
    end
  end

  should 'show profile nickname on title' do
    profile.update_attributes(:nickname => 'my nick')
    get :index, :profile => profile.identifier
    assert_tag :tag => 'h1', :attributes => { :class => 'block-title'}, :descendant => {
      :tag => 'span', :attributes => { :class => 'control-panel-title' }, :content => 'my nick'
    }
  end

  should 'show profile name on title when no nickname' do
    get :index, :profile => profile.identifier
    assert_tag :tag => 'h1', :attributes => { :class => 'block-title'}, :descendant => {
      :tag => 'span', :attributes => { :class => 'control-panel-title' }, :content => profile.identifier
    }
  end

  should 'render destroy_profile template' do
    community = fast_create(Community)
    get :destroy_profile, :profile => community.identifier
    assert_template 'destroy_profile'
  end

  should 'be able to destroy a person' do
    person = fast_create(Person)

    assert_difference Person, :count, -1 do
      post :destroy_profile, :profile => person.identifier
    end
  end

  should 'be able to destroy communities' do
    community = fast_create(Community)

    person = fast_create(Person)
    community.add_admin(person)

    assert_difference Community, :count, -1 do
      post :destroy_profile, :profile => community.identifier
    end
  end

  should 'not be able to destroy communities if is a regular member' do
    community = fast_create(Community)

    person = fast_create(Person)
    community.add_admin(person)

    login_as(person.identifier)
    assert_difference Community, :count, 0 do
      post :destroy_profile, :profile => community.identifier
    end
  end

  should 'be able to destroy enterprise' do
    enterprise = fast_create(Enterprise)

    person = fast_create(Person)
    enterprise.add_admin(person)

    assert_difference Enterprise, :count, -1 do
      post :destroy_profile, :profile => enterprise.identifier
    end
  end

  should 'not be able to destroy enterprise if is a regular member' do
    enterprise = fast_create(Enterprise)

    person = fast_create(Person)
    enterprise.add_admin(person)

    login_as(person.identifier)
    assert_difference Enterprise, :count, 0 do
      post :destroy_profile, :profile => enterprise.identifier
    end
  end

  should 'display plugins buttons on the control panel' do
    plugin1_button = {:title => "Plugin1 button", :icon => 'plugin1_icon', :url => 'plugin1_url'}
    plugin2_button = {:title => "Plugin2 button", :icon => 'plugin2_icon', :url => 'plugin2_url'}
    buttons = [plugin1_button, plugin2_button]
    plugins = mock()
    plugins.stubs(:map).with(:control_panel_buttons).returns(buttons)
    Noosfero::Plugin::Manager.stubs(:new).returns(plugins)

    get :index, :profile => profile.identifier

    assert_tag :tag => 'a', :content => plugin1_button[:title], :attributes => {:class => /#{plugin1_button[:icon]}/, :href => /#{plugin1_button[:url]}/}
    assert_tag :tag => 'a', :content => plugin2_button[:title], :attributes => {:class => /#{plugin2_button[:icon]}/, :href => /#{plugin2_button[:url]}/}
  end

end
