require File.dirname(__FILE__) + '/../test_helper'
require 'profile_editor_controller'

# Re-raise errors caught by the controller.
class ProfileEditorController; def rescue_action(e) raise e end; end

class ProfileEditorControllerTest < Test::Unit::TestCase
  all_fixtures
  
  def setup
    @controller = ProfileEditorController.new
    @request    = ActionController::TestRequest.new
    @request.stubs(:ssl?).returns(true)
    @response   = ActionController::TestResponse.new
    @profile = create_user('default_user').person
    Environment.default.affiliate(@profile, [Environment::Roles.admin] + Profile::Roles.all_roles)
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
    person = create_user('test_profile').person
    person.name = 'a test profile'
    person.address = 'my address'
    person.contact_information = 'my contact information'
    person.save!

    get :index, :profile => person.identifier
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
    person = create_user('test_profile', :email => 'test@noosfero.org', :password => 'test', :password_confirmation => 'test').person
    get :edit, :profile => person.identifier
    assert_response :success
    assert_template 'edit'
  end

  should 'saving profile info' do
    person = create_user('test_profile').person
    post :edit, :profile => 'test_profile', :profile_data => { 'name' => 'new person', 'contact_information' => 'new contact information', 'address' => 'new address', 'sex' => 'female' }
    assert_redirected_to :action => 'index'
    person = Person.find(person.id)
    assert_equal 'new person', person.name
    assert_equal 'new contact information', person.contact_information
    assert_equal 'new address', person.address
    assert_equal 'female', person.sex
  end

  should 'not permmit if not logged' do
    logout
    person = create_user('test_user')
    get :index, :profile => 'test_user'
  end

  should 'display categories to choose to associate profile' do
    cat1 = Environment.default.categories.build(:display_in_menu => true, :name => 'top category'); cat1.save!
    cat2 = Environment.default.categories.build(:display_in_menu => true, :name => 'sub category', :parent => cat1); cat2.save!
    person = create_user('test_user').person
    get :edit, :profile => 'test_user'
    assert_response :success
    assert_template 'edit'
    assert_tag :tag => 'input', :attributes => {:name => 'profile_data[category_ids][]', :value => cat2.id}
  end

  should 'save categorization of profile' do
    cat1 = Environment.default.categories.build(:name => 'top category'); cat1.save!
    cat2 = Environment.default.categories.build(:name => 'sub category', :parent => cat1); cat2.save!
    person = create_user('test_user').person
    post :edit, :profile => 'test_user', :profile_data => {:category_ids => [cat2.id]}
    assert_response :redirect
    assert_redirected_to :action => 'index'
    assert_includes person.categories, cat2
  end

  should 'filter html from name when edit person_info' do
    person = create_user('test_profile').person
    name = "name <strong id='name_html_test'>with</strong> html"
    post :edit, :profile => person.identifier, :profile_data => { :name => name }
    assert_sanitized assigns(:profile).name
  end

  should 'filter html from contact_person to organization' do
    org = Organization.create!(:name => 'test org', :identifier => 'testorg', :environment => Environment.default)
    contact = "name <strong id='name_html_test'>with</strong> html"
    post :edit, :profile => org.identifier, :profile_data => { :contact_person => contact }
    assert_sanitized assigns(:profile).contact_person
  end

  should 'filter html from acronym organization' do
    org = Organization.create!(:name => 'test org', :identifier => 'testorg', :environment => Environment.default)
    value = "name <strong id='name_html_test'>with</strong> html"
    post :edit, :profile => org.identifier, :profile_data => { :acronym => value }
    assert_sanitized assigns(:profile).acronym
  end

  should 'filter html from legal_form organization' do
    org = Organization.create!(:name => 'test org', :identifier => 'testorg', :environment => Environment.default)
    value = "name <strong id='name_html_test'>with</strong> html"
    post :edit, :profile => org.identifier, :profile_data => { :legal_form => value }
    assert_sanitized assigns(:profile).legal_form
  end

  should 'filter html from economic_activity organization' do
    org = Organization.create!(:name => 'test org', :identifier => 'testorg', :environment => Environment.default)
    value = "name <strong id='name_html_test'>with</strong> html"
    post :edit, :profile => org.identifier, :profile_data => { :economic_activity => value }
    assert_sanitized assigns(:profile).economic_activity
  end

  should 'filter html from management_information organization' do
    org = Organization.create!(:name => 'test org', :identifier => 'testorg', :environment => Environment.default)
    value = "name <strong id='name_html_test'>with</strong> html"
    post :edit, :profile => org.identifier, :profile_data => { :management_information => value }
    assert_sanitized assigns(:profile).management_information
  end

  should 'saving profile organization_info' do
    org = Organization.create!(:name => 'test org', :identifier => 'testorg', :environment => Environment.default)
    post :edit, :profile => 'testorg', :profile_data => { :contact_person => 'contact person' }
    assert_equal 'contact person', Organization.find(org.id).contact_person
  end

  should 'show contact_phone field on edit enterprise' do
    org = Enterprise.create!(:name => 'test org', :identifier => 'testorg', :environment => Environment.default)
    Enterprise.any_instance.expects(:active_fields).returns(['contact_phone']).at_least_once
    get :edit, :profile => org.identifier
    assert_tag :tag => 'input', :attributes => { :name => 'profile_data[contact_phone]' }
  end

  should 'save community description' do
    org = Community.create!(:name => 'test org', :identifier => 'testorg', :environment => Environment.default)
    post :edit, :profile => 'testorg', :profile_data => { :description => 'my description' }
    assert_equal 'my description', Organization.find(org.id).description
  end

  should 'show community description' do
    org = Community.create!(:name => 'test org', :identifier => 'testorg', :environment => Environment.default)
    Community.any_instance.expects(:active_fields).returns(['description']).at_least_once
    get :edit, :profile => 'testorg'
    assert_tag :tag => 'textarea', :attributes => { :name => 'profile_data[description]' }
  end

  should 'not show enterprise description' do
    org = Enterprise.create!(:name => 'test org', :identifier => 'testorg', :environment => Environment.default)
    get :edit, :profile => 'testorg'
    assert_no_tag :tag => 'textarea', :attributes => { :name => 'profile_data[description]' }
  end

  should 'save organization contact_person' do
    org = Organization.create!(:name => 'test org', :identifier => 'testorg')
    post :edit, :profile => 'testorg', :profile_data => { :contact_person => 'my contact' }
    assert_equal 'my contact', Organization.find(org.id).contact_person
  end

  should 'save enterprise contact_person' do
    org = Enterprise.create!(:name => 'test org', :identifier => 'testorg', :environment => Environment.default)
    post :edit, :profile => 'testorg', :profile_data => { :contact_person => 'my contact' }
    assert_equal 'my contact', Enterprise.find(org.id).contact_person
  end

  should 'show field values on edit community info' do
    Community.any_instance.expects(:active_fields).returns(['contact_person']).at_least_once
    org = Community.create!(:name => 'test org', :identifier => 'testorg', :environment => Environment.default)
    org.contact_person = 'my contact'
    org.save!
    get :edit, :profile => 'testorg'
    assert_tag :tag => 'input', :attributes => { :name => 'profile_data[contact_person]', :value => 'my contact' }
  end

  should 'show field values on edit enterprise info' do
    Enterprise.any_instance.expects(:active_fields).returns(['contact_person']).at_least_once
    org = Enterprise.create!(:name => 'test org', :identifier => 'testorg', :environment => Environment.default)
    org.contact_person = 'my contact'
    org.save!
    get :edit, :profile => 'testorg'
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
    org = Community.create!(:name => 'test org', :identifier => 'testorg', :environment => Environment.default)
    post :edit, :profile => 'testorg', :profile_data => { :foundation_year => 'aaa' }
    assert_tag :tag => 'div', :attributes => { :id => 'errorExplanation' }
  end

  should 'edit enterprise' do
    ent = Enterprise.create!(:name => 'test org', :identifier => 'testent', :environment => Environment.default)
    get :edit, :profile => 'testent'
    assert_response :success
  end

  should 'back when update community info fail' do
    org = Community.create!(:name => 'test org', :identifier => 'testorg', :contact_person => 'my contact', :environment => Environment.default)
    Community.any_instance.stubs(:update_attributes).returns(false)
    post :edit, :profile => 'testorg'
    assert_template 'edit'
  end

  should 'back when update enterprise info fail' do
    org = Enterprise.create!(:name => 'test org', :identifier => 'testorg', :contact_person => 'my contact', :environment => Environment.default)
    Enterprise.any_instance.stubs(:update_attributes).returns(false)
    post :edit, :profile => 'testorg'
    assert_template 'edit'
  end

  should 'show edit profile button' do
    person = create_user('testuser').person
    get :index, :profile => 'testuser'
    assert_tag :tag => 'div', :attributes => { :class => 'file-manager-button' }, :child => { :tag => 'a', :attributes => { :href => '/myprofile/testuser/profile_editor/edit' } }
  end

  should 'show image field on edit profile' do
    person = create_user('testuser').person
    get :edit, :profile => 'testuser'
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
    person = create_user('test_profile').person
    get :edit, :profile => person.identifier
    assert_template 'edit'
  end

  should 'render person partial' do
    person = create_user('test_profile', :environment => Environment.default).person
    Person.any_instance.expects(:active_fields).returns(['contact_phone', 'address']).at_least_once
    get :edit, :profile => person.identifier
    person.active_fields.each do |field|
      assert_tag :tag => 'input', :attributes => { :name => "profile_data[#{field}]" }
    end
  end

  should 'display only active person fields' do
    Person.any_instance.expects(:active_fields).returns(['cell_phone']).at_least_once
    person = create_user('test_profile').person

    get :edit, :profile => person.identifier

    assert_tag :tag => 'input', :attributes => { :name => "profile_data[cell_phone]" }
    assert_no_tag :tag => 'input', :attributes => { :name => "profile_data[comercial_phone]" }
  end

  should 'be able to upload an image' do
    person = create_user('test_profile').person
    assert_nil person.image
    post :edit, :profile => 'test_profile', :profile_data => { :image_builder => { :uploaded_data => fixture_file_upload('/files/rails.png', 'image/png') } }
    assert_not_nil assigns(:profile).image
  end

  should 'display closed attribute for enterprise when it is set' do
    org = Enterprise.create!(:name => 'test org', :identifier => 'testorg', :contact_person => 'my contact', :closed => true, :environment => Environment.default)
    get :edit, :profile => 'testorg'

    assert_tag :tag => 'input', :attributes => { :type => 'radio', :name => 'profile_data[closed]', :value => 'true', :checked => 'checked' }
    assert_no_tag :tag => 'input', :attributes => { :type => 'radio', :name => 'profile_data[closed]', :value => 'false', :checked =>  'checked' }
  end

  should 'display closed attribute for organizations when it is set' do
    org = Organization.create!(:name => 'test org', :identifier => 'testorg', :contact_person => 'my contact', :closed => true, :environment => Environment.default)
    get :edit, :profile => 'testorg'

    assert_tag :tag => 'input', :attributes => { :type => 'radio', :name => 'profile_data[closed]', :value => 'true', :checked => 'checked' }
    assert_no_tag :tag => 'input', :attributes => { :type => 'radio', :name => 'profile_data[closed]', :value => 'false', :checked =>  'checked' }
  end

  should 'display closed attribute for organizations when it is set to false' do
    org = Organization.create!(:name => 'test org', :identifier => 'testorg', :contact_person => 'my contact', :closed => false)
    get :edit, :profile => 'testorg'
    assert_no_tag :tag => 'input', :attributes => { :type => 'radio', :name => 'profile_data[closed]', :value => 'true', :checked => 'checked' }
    assert_tag :tag => 'input', :attributes => { :type => 'radio', :name => 'profile_data[closed]', :value => 'false', :checked => 'checked' }
  end

  should 'display closed attribute for organizations when it is set to nothing at all' do
    org = Organization.create!(:name => 'test org', :identifier => 'testorg', :contact_person => 'my contact', :closed => nil)
    get :edit, :profile => 'testorg'
    assert_no_tag :tag => 'input', :attributes => { :type => 'radio', :name => 'profile_data[closed]', :value => 'true', :checked => 'checked' }
    assert_tag :tag => 'input', :attributes => { :type => 'radio', :name => 'profile_data[closed]', :value => 'false', :checked => 'checked' }
  end

  should 'set closed attribute correctly' do
    org = Organization.create!(:name => 'test org', :identifier => 'testorg', :contact_person => 'my contact', :closed => false)

    post :edit, :profile => 'testorg', :profile_data => { :closed => 'true' }
    org.reload
    assert org.closed
  end

  should 'unset closed attribute correctly' do
    org = Organization.create!(:name => 'test org', :identifier => 'testorg', :contact_person => 'my contact', :closed => true)

    post :edit, :profile => 'testorg', :profile_data => { :closed => 'false' }
    org.reload
    assert !org.closed
  end

  should 'display manage members options if has permission' do
    profile = Profile['ze']
    community = Community.create!(:name => 'test org', :identifier => 'testorg', :contact_person => 'my contact', :environment => Environment.default)
    @controller.stubs(:user).returns(profile)
    @controller.stubs(:profile).returns(community)
    profile.stubs(:has_permission?).returns(true)
    get :index, :profile => 'testorg'
    assert_tag :tag => 'a', :content => 'Manage Members'
  end

  should 'not display manage members options if has no permission' do
    profile = Profile['ze']
    community = Community.create!(:name => 'test org', :identifier => 'testorg', :contact_person => 'my contact', :environment => Environment.default)
    @controller.stubs(:user).returns(profile)
    @controller.stubs(:profile).returns(community)
    profile.stubs(:has_permission?).returns(false)
    get :index, :profile => 'testorg'
    assert_no_tag :tag => 'a', :content => 'Manage Members'
  end

  should 'render enterprise partial' do
    ent = Enterprise.create(:name => 'test_profile', :identifier => 'testorg', :environment => Environment.default)
    Enterprise.any_instance.expects(:active_fields).returns(['contact_phone', 'contact_person', 'contact_email']).at_least_once
    get :edit, :profile => ent.identifier
    ent.active_fields.each do |field|
      assert_tag :tag => 'input', :attributes => { :name => "profile_data[#{field}]" }
    end
  end

  should 'render community partial' do
    community = Community.create(:name => 'test_profile', :identifier => 'testorg', :environment => Environment.default)
    Community.any_instance.expects(:active_fields).returns(['contact_person', 'language']).at_least_once
    get :edit, :profile => community.identifier
    community.active_fields.each do |field|
      assert_tag :tag => 'input', :attributes => { :name => "profile_data[#{field}]" }
    end
  end

  should 'show task if user has permission' do
    user1 = create_user('userone').person
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
    user1 = create_user('userone').person
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
    person = create_user('testuser').person
    get :index, :profile => 'testuser'
    assert_tag :tag => 'a', :content => 'Favorite Enterprises'
  end

  should 'not show favorite enterprises button for organization' do
    org = Organization.create!(:name => 'test org', :identifier => 'testorg', :contact_person => 'my contact')
    get :index, :profile => 'testorg'
    assert_no_tag :tag => 'a', :content => 'Favorite Enterprises'
  end

  should 'link to mailconf' do
    MailConf.expects(:enabled?).returns(true).at_least_once
    get :index, :profile => profile.identifier
    assert_tag :tag => 'a', :attributes => { :href => "/myprofile/#{profile.identifier}/mailconf" }
  end

  should 'not link to mailconf for organizations' do
    MailConf.stubs(:enabled?).returns(true).at_least_once
    org = Organization.create!(:name => 'test org', :identifier => 'testorg', :contact_person => 'my contact')
    get :index, :profile => 'testorg'
    assert_no_tag :tag => 'a', :attributes => { :href => '/myprofile/testorg/mailconf' }
  end

  should 'not link to mailconf if mail not enabled' do
    MailConf.expects(:enabled?).returns(false).at_least_once
    get :index, :profile => profile.identifier
    assert_no_tag :tag => 'a', :attributes => { :href => "/myprofile/#{profile.identifier}/mailconf" }
  end

  should 'link to enable enterprise' do
    ent = Enterprise.create!(:name => 'test org', :identifier => 'testent', :enabled => false, :environment => Environment.default)
    get :index, :profile => 'testent'
    assert_tag :tag => 'a', :attributes => { :href => '/myprofile/testent/profile_editor/enable' }
  end
  
  should 'link to disable enterprise' do
    ent = Enterprise.create!(:name => 'test org', :identifier => 'testent', :enabled => true, :environment => Environment.default)
    get :index, :profile => 'testent'
    assert_tag :tag => 'a', :attributes => { :href => '/myprofile/testent/profile_editor/disable' }
  end

  should 'not link to enable/disable for non enterprises' do
    ent = Organization.create!(:name => 'test org', :identifier => 'testorg', :enabled => true)
    get :index, :profile => 'testorg'
    assert_no_tag :tag => 'a', :attributes => { :href => '/myprofile/testorg/profile_editor/disable' }
  end

  should 'request enable enterprise confirmation' do
    ent = Enterprise.create!(:name => 'test org', :identifier => 'testent', :enabled => false, :environment => Environment.default)
    get :enable, :profile => 'testent'
    assert_tag :tag => 'form', :attributes => { :action => '/myprofile/testent/profile_editor/enable', :method => 'post' }
  end

  should 'enable enterprise after confirmation' do
    ent = Enterprise.create!(:name => 'test org', :identifier => 'testent', :enabled => false, :environment => Environment.default)
    post :enable, :profile => 'testent', :confirmation => 1
    assert assigns(:to_enable).enabled?
  end

  should 'not enable enterprise without confirmation' do
    ent = Enterprise.create!(:name => 'test org', :identifier => 'testent', :enabled => false, :environment => Environment.default)
    post :enable, :profile => 'testent'
    assert !assigns(:to_enable).enabled?
  end

  should 'disable enterprise after confirmation' do
    ent = Enterprise.create!(:name => 'test org', :identifier => 'testent', :enabled => true, :environment => Environment.default)
    post :disable, :profile => 'testent', :confirmation => 1
    assert !assigns(:to_disable).enabled?
  end

  should 'not disable enterprise without confirmation' do
    ent = Enterprise.create!(:name => 'test org', :identifier => 'testent', :enabled => true, :environment => Environment.default)
    post :disable, :profile => 'testent'
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
    person = create_user('testuser').person
    get :index, :profile => 'testuser'
    assert_tag :tag => 'a', :content => 'Manage my groups'
  end

  should 'display footer edit screen' do

    person = create_user('designtestuser').person
    person.custom_header = 'my custom header'
    person.custom_footer = 'my custom footer'
    person.save!

    get :header_footer, :profile => 'designtestuser'
    assert_tag :tag => 'textarea', :content => 'my custom header'
    assert_tag :tag => 'textarea', :content => 'my custom footer'
  end

  should 'save footer and header' do
    person = create_user('designtestuser').person
    post :header_footer, :profile => 'designtestuser', :custom_header => 'new header', :custom_footer => 'new footer'
    person = Person.find(person.id)
    assert_equal 'new header', person.custom_header
    assert_equal 'new footer', person.custom_footer
  end

  should 'go back to editor after saving header/footer' do
    person = create_user('designtestuser').person
    post :header_footer, :profile => 'designtestuser', :custom_header => 'new header', :custom_footer => 'new footer'
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

    enterprise = Enterprise.create!(:name => 'Enterprise for test', :identifier => 'enterprise_for_test')

    u = create_user_with_permission('test_user', 'edit_profile', enterprise)
    login_as('test_user')

    get :index, :profile => enterprise.identifier
    assert_no_tag :tag => 'a', :attributes => { :href => "/myprofile/enterprise_for_test/profile_editor/header_footer" }
  end

  should 'display header/footer button to enterprises if the environment disabled it but user is admin' do
    env = Environment.default
    env.enable('disable_header_and_footer')
    env.save!

    enterprise = Enterprise.create!(:name => 'Enterprise for test', :identifier => 'enterprise_for_test')

    Person.any_instance.expects(:is_admin?).returns(true).at_least_once

    get :index, :profile => enterprise.identifier
    assert_tag :tag => 'a', :attributes => { :href => "/myprofile/enterprise_for_test/profile_editor/header_footer" }
  end

  should 'not list the manage products button if the environment disabled it' do
    env = Environment.default
    env.enable('disable_products_for_enterprises')
    env.save!
    ent = Enterprise.create!(:name => 'test enterprise', :identifier => 'test_ent', :environment => env)

    u = create_user_with_permission('test_user', 'edit_profile', ent)
    login_as('test_user')

    get :index, :profile => 'test_ent'

    assert_no_tag :tag => 'span', :content => 'Manage Products and Services'
  end

  should 'display categories if environment disable_categories disabled' do
    Environment.any_instance.stubs(:enabled?).with(anything).returns(false)
    person = create_user('test_profile', :email => 'test@noosfero.org', :password => 'test', :password_confirmation => 'test').person
    get :edit, :profile => person.identifier
    assert_tag :tag => 'div', :descendant => { :tag => 'h2', :content => 'Select the categories of your interest' }
  end

  should 'not display categories if environment disable_categories enabled' do
    Environment.any_instance.stubs(:enabled?).with(anything).returns(true)
    person = create_user('test_profile', :email => 'test@noosfero.org', :password => 'test', :password_confirmation => 'test').person
    get :edit, :profile => person.identifier
    assert_no_tag :tag => 'div', :descendant => { :tag => 'h2', :content => 'Select the categories of your interest' }
  end

  should 'show a e-mail field in profile editor' do
    create_user('test_user', :email=>'teste_user@teste.com')
    login_as('test_user')
    get :edit, :profile => 'test_user'

    assert_tag :tag => 'input',
               :attributes => { :name=>'profile_data[email]', :value=>'teste_user@teste.com' }
  end

  should 'display enable contact us for enterprise' do
    org = Enterprise.create!(:name => 'test org', :identifier => 'testorg')
    get :edit, :profile => 'testorg'
    assert_tag :tag => 'input', :attributes => {:name => 'profile_data[enable_contact_us]', :type => 'checkbox'}
  end

  should 'display link to CMS' do
    get :index, :profile => 'default_user'
    assert_tag :tag => 'a', :attributes => { :href => '/myprofile/default_user/cms' }
  end

  should 'not display link to CMS if disabled' do
    env = Environment.default
    env.enable('disable_cms')
    env.save!
    get :index, :profile => 'default_user'

    assert_no_tag :tag => 'a', :attributes => { :href => '/myprofile/default_user/cms' }
  end

  should 'offer to create blog in control panel' do
    get :index, :profile => 'default_user'
    assert_tag :tag => 'a', :attributes => { :href => "/myprofile/default_user/cms/new?type=Blog" }
  end

  should 'offer to config blog in control panel' do
    profile.articles << Blog.new(:name => 'My blog', :profile => profile)
    get :index, :profile => profile.identifier
    assert_tag :tag => 'a', :attributes => { :href => "/myprofile/default_user/cms/edit/#{profile.blog.id}" }
  end

end
