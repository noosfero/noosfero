require File.dirname(__FILE__) + '/../test_helper'
require 'profile_editor_controller'

# Re-raise errors caught by the controller.
class ProfileEditorController; def rescue_action(e) raise e end; end

class ProfileEditorControllerTest < Test::Unit::TestCase
  all_fixtures
  
  def setup
    @controller = ProfileEditorController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    login_as('ze')
  end

  def test_local_files_reference
    assert_local_files_reference :get, :index, :profile => 'ze'
  end
  
  def test_valid_xhtml
    assert_valid_xhtml
  end
  
  def test_index
    person = User.create(:login => 'test_profile', :email => 'test@noosfero.org', :password => 'test', :password_confirmation => 'test').person
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
    tasks.expects(:pending).returns(pending)
    ze.expects(:tasks).returns(tasks)
    get :index, :profile => ze.identifier
    assert_same pending, assigns(:pending_tasks)
    assert_tag :tag => 'div', :attributes => { :class => 'pending-tasks' }, :descendant => { :tag => 'a', :attributes =>  { :href => '/myprofile/ze/tasks' } }
  end

  def test_edit_person_info
    person = User.create(:login => 'test_profile', :email => 'test@noosfero.org', :password => 'test', :password_confirmation => 'test').person
    assert person.valid?
    get :edit, :profile => person.identifier
    assert_response :success
    assert_template 'edit'
  end

  should 'saving profile info' do
    person = create_user('test_profile').person
    post :edit, :profile => 'test_profile', :profile_data => { 'name' => 'new person', 'contact_information' => 'new contact information', 'address' => 'new address', 'sex' => 'female' }
    assert_redirected_to :action => 'index'
    person.reload
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
    org = Organization.create!(:name => 'test org', :identifier => 'testorg')
    contact = "name <strong id='name_html_test'>with</strong> html"
    post :edit, :profile => org.identifier, :profile_data => { :contact_person => contact }
    assert_sanitized assigns(:profile).contact_person
  end

  should 'filter html from acronym organization' do
    org = Organization.create!(:name => 'test org', :identifier => 'testorg')
    value = "name <strong id='name_html_test'>with</strong> html"
    post :edit, :profile => org.identifier, :profile_data => { :acronym => value }
    assert_sanitized assigns(:profile).acronym
  end

  should 'filter html from legal_form organization' do
    org = Organization.create!(:name => 'test org', :identifier => 'testorg')
    value = "name <strong id='name_html_test'>with</strong> html"
    post :edit, :profile => org.identifier, :profile_data => { :legal_form => value }
    assert_sanitized assigns(:profile).legal_form
  end

  should 'filter html from economic_activity organization' do
    org = Organization.create!(:name => 'test org', :identifier => 'testorg')
    value = "name <strong id='name_html_test'>with</strong> html"
    post :edit, :profile => org.identifier, :profile_data => { :economic_activity => value }
    assert_sanitized assigns(:profile).economic_activity
  end

  should 'filter html from management_information organization' do
    org = Organization.create!(:name => 'test org', :identifier => 'testorg')
    value = "name <strong id='name_html_test'>with</strong> html"
    post :edit, :profile => org.identifier, :profile_data => { :management_information => value }
    assert_sanitized assigns(:profile).management_information
  end

  should 'saving profile organization_info' do
    org = Organization.create!(:name => 'test org', :identifier => 'testorg')
    post :edit, :profile => 'testorg', :profile_data => { :contact_person => 'contact person' }
    assert_equal 'contact person', Organization.find(org.id).contact_person
  end

  should 'show contact_person field on edit organization' do
    org = Organization.create!(:name => 'test org', :identifier => 'testorg')
    get :edit, :profile => org.identifier
    assert_tag :tag => 'input', :attributes => { :name => 'profile_data[contact_person]' }
  end

  should 'save community description' do
    org = Community.create!(:name => 'test org', :identifier => 'testorg')
    post :edit, :profile => 'testorg', :profile_data => { :description => 'my description' }
    assert_equal 'my description', Organization.find(org.id).description
  end

  should 'show community description' do
    org = Community.create!(:name => 'test org', :identifier => 'testorg')
    get :edit, :profile => 'testorg'
    assert_tag :tag => 'textarea', :attributes => { :name => 'profile_data[description]' }
  end

  should 'not show organization description' do
    org = Organization.create!(:name => 'test org', :identifier => 'testorg')
    get :edit, :profile => 'testorg'
    assert_no_tag :tag => 'textarea', :attributes => { :name => 'profile_data[description]' }
  end

  should 'save organization contact_person' do
    org = Organization.create!(:name => 'test org', :identifier => 'testorg')
    post :edit, :profile => 'testorg', :profile_data => { :contact_person => 'my contact' }
    assert_equal 'my contact', Organization.find(org.id).contact_person
  end

  should 'save enterprise contact_person' do
    org = Enterprise.create!(:name => 'test org', :identifier => 'testorg')
    post :edit, :profile => 'testorg', :profile_data => { :contact_person => 'my contact' }
    assert_equal 'my contact', Enterprise.find(org.id).contact_person
  end

  should 'show field values on edit organization info' do
    org = Organization.create!(:name => 'test org', :identifier => 'testorg')
    org.contact_person = 'my contact'
    org.save!
    get :edit, :profile => 'testorg'
    assert_tag :tag => 'input', :attributes => { :name => 'profile_data[contact_person]', :value => 'my contact' }
  end

  should 'display profile publication option in edit profile screen' do
    profile = Profile['ze']
    get :edit, :profile => 'ze'
    assert_tag :tag => 'input', :attributes => { :type => 'radio', :checked => 'checked', :name => 'profile_data[public_profile]', :value => 'true' }
    assert_tag :tag => 'input', :attributes => { :type => 'radio', :name => 'profile_data[public_profile]', :value => 'false' }
  end

  should 'display properly that the profile is non-public' do
    profile = Profile['ze']
    profile.update_attributes!(:public_profile => false)
    get :edit, :profile => 'ze'
    assert_tag :tag => 'input', :attributes => { :type => 'radio', :checked => 'checked', :name => 'profile_data[public_profile]', :value => 'false' }
    assert_tag :tag => 'input', :attributes => { :type => 'radio', :name => 'profile_data[public_profile]', :value => 'true' }
  end

  should 'save profile publication option set to true' do
    post :edit, :profile => 'ze', :profile_data => { :public_profile => 'true' }
    assert_equal true, Profile['ze'].public_profile
  end

  should 'save profile publication option set to false' do
    post :edit, :profile => 'ze', :profile_data => { :public_profile => 'false' }
    assert_equal false, Profile['ze'].public_profile
  end

  should 'display public_content field for editing' do
    profile = Profile['ze']
    get :edit, :profile => 'ze'
    assert_tag :tag => 'input', :attributes => { :type => 'radio', :checked => 'checked', :name => 'profile_data[public_content]', :value => 'true' }
    assert_tag :tag => 'input', :attributes => { :type => 'radio', :name => 'profile_data[public_content]', :value => 'false' }
  end

  should 'display properly that the content is non-public' do
    profile = Profile['ze']
    profile.update_attributes(:public_content => false)
    get :edit, :profile => 'ze'
    assert_tag :tag => 'input', :attributes => { :type => 'radio', :checked => 'checked', :name => 'profile_data[public_content]', :value => 'false' }
    assert_tag :tag => 'input', :attributes => { :type => 'radio', :name => 'profile_data[public_content]', :value => 'true' }
  end

  should 'show error messages for invalid foundation_year' do
    org = Organization.create!(:name => 'test org', :identifier => 'testorg')
    post :edit, :profile => 'testorg', :profile_data => { :foundation_year => 'aaa' }
    assert_tag :tag => 'div', :attributes => { :id => 'errorExplanation' }
  end

  should 'edit enterprise' do
    ent = Enterprise.create!(:name => 'test org', :identifier => 'testent')
    get :edit, :profile => 'testent'
    assert_response :success
  end

  should 'back when update organization info fail' do
    org = Organization.create!(:name => 'test org', :identifier => 'testorg', :contact_person => 'my contact')
    Organization.any_instance.stubs(:update_attributes).returns(false)
    post :edit, :profile => 'testorg'
    assert_template 'edit'
  end

  should 'show edit profile button' do
    person = create_user('testuser').person
    get :index, :profile => 'testuser'
    assert_tag :tag => 'a', :content => 'Edit Profile'
  end

  should 'show image field on edit profile' do
    person = create_user('testuser').person
    get :edit, :profile => 'testuser'
    assert_tag :tag => 'input', :attributes => { :name => 'profile_data[image_builder][uploaded_data]' }
  end

  should 'show categories field on edit profile' do
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
    person = create_user('test_profile').person
    get :edit, :profile => person.identifier
    assert_tag :tag => 'input', :attributes => { :name => 'profile_data[contact_phone]' }
  end

  should 'be able to upload an image' do
    person = create_user('test_profile').person
    assert_nil person.image
    post :edit, :profile => 'test_profile', :profile_data => { :image_builder => { :uploaded_data => fixture_file_upload('/files/rails.png', 'image/png') } }
    assert_not_nil assigns(:profile).image
  end

  should 'show field to set closed organization' do
    org = Organization.create!(:name => 'test org', :identifier => 'testorg', :contact_person => 'my contact')
    get :edit, :profile => 'testorg'
    assert_tag :tag => 'input', :attributes => { :type => 'checkbox', :name => 'profile_data[closed]' }
  end

  should 'display manage members options if has permission' do
    profile = Profile['ze']
    community = Community.create!(:name => 'test org', :identifier => 'testorg', :contact_person => 'my contact')
    @controller.stubs(:user).returns(profile)
    @controller.stubs(:profile).returns(community)
    profile.stubs(:has_permission?).returns(true)
    get :index, :profile => 'testorg'
    assert_tag :tag => 'a', :content => 'Manage Members'
  end

  should 'not display manage members options if has no permission' do
    profile = Profile['ze']
    community = Community.create!(:name => 'test org', :identifier => 'testorg', :contact_person => 'my contact')
    @controller.stubs(:user).returns(profile)
    @controller.stubs(:profile).returns(community)
    profile.stubs(:has_permission?).returns(false)
    get :index, :profile => 'testorg'
    assert_no_tag :tag => 'a', :content => 'Manage Members'
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
    get :index, :profile => 'ze'
    assert_tag :tag => 'a', :attributes => { :href => '/myprofile/ze/mailconf' }
  end

  should 'not link to mailconf for organizations' do
    MailConf.stubs(:enabled?).returns(true).at_least_once
    org = Organization.create!(:name => 'test org', :identifier => 'testorg', :contact_person => 'my contact')
    get :index, :profile => 'testorg'
    assert_no_tag :tag => 'a', :attributes => { :href => '/myprofile/testorg/mailconf' }
  end

  should 'not link to mailconf if mail not enabled' do
    MailConf.expects(:enabled?).returns(false).at_least_once
    get :index, :profile => 'ze'
    assert_no_tag :tag => 'a', :attributes => { :href => '/myprofile/ze/mailconf' }
  end

  should 'link to enable enterprise' do
    ent = Enterprise.create!(:name => 'test org', :identifier => 'testent', :enabled => false)
    get :index, :profile => 'testent'
    assert_tag :tag => 'a', :attributes => { :href => '/myprofile/testent/profile_editor/enable' }
  end
  
  should 'link to disable enterprise' do
    ent = Enterprise.create!(:name => 'test org', :identifier => 'testent', :enabled => true)
    get :index, :profile => 'testent'
    assert_tag :tag => 'a', :attributes => { :href => '/myprofile/testent/profile_editor/disable' }
  end

  should 'not link to enable/disable for non enterprises' do
    ent = Organization.create!(:name => 'test org', :identifier => 'testorg', :enabled => true)
    get :index, :profile => 'testorg'
    assert_no_tag :tag => 'a', :attributes => { :href => '/myprofile/testorg/profile_editor/disable' }
  end

  should 'request enable enterprise confirmation' do
    ent = Enterprise.create!(:name => 'test org', :identifier => 'testent', :enabled => false)
    get :enable, :profile => 'testent'
    assert_tag :tag => 'form', :attributes => { :action => '/myprofile/testent/profile_editor/enable', :method => 'post' }
  end

  should 'enable enterprise after confirmation' do
    ent = Enterprise.create!(:name => 'test org', :identifier => 'testent', :enabled => false)
    post :enable, :profile => 'testent', :confirmation => 1
    assert assigns(:to_enable).enabled?
  end

  should 'not enable enterprise without confirmation' do
    ent = Enterprise.create!(:name => 'test org', :identifier => 'testent', :enabled => false)
    post :enable, :profile => 'testent'
    assert !assigns(:to_enable).enabled?
  end

  should 'disable enterprise after confirmation' do
    ent = Enterprise.create!(:name => 'test org', :identifier => 'testent', :enabled => true)
    post :disable, :profile => 'testent', :confirmation => 1
    assert !assigns(:to_disable).enabled?
  end

  should 'not disable enterprise without confirmation' do
    ent = Enterprise.create!(:name => 'test org', :identifier => 'testent', :enabled => true)
    post :disable, :profile => 'testent'
    assert assigns(:to_disable).enabled?
  end

  should 'link to create community' do
    profile = Person['ze']
    get :index, :profile => profile.identifier
    assert_tag :tag => 'a', :attributes => { :href => "/myprofile/#{profile.identifier}/memberships/new_community" }
  end
  
end
