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

    assert_tag :tag => 'td', :content => 'a test profile'
    assert_tag :tag => 'td', :content => 'my address'
    assert_tag :tag => 'td', :content => 'my contact information'
  end

  def test_should_present_pending_tasks_in_index
    ze = Profile['ze'] # a fixture >:-(
    @controller.expects(:profile).returns(ze).at_least_once
    tasks = mock
    pending = []
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
    assert_template 'person'
  end

  def test_saving_profile_info 
    person = User.create(:login => 'test_profile', :email => 'test@noosfero.org', :password => 'test', :password_confirmation => 'test').person
    person.address = 'my address'
    person.contact_information = 'my contact information'
    person.save!
    
    post :edit, :profile => 'test_profile', :profile_data => { 'contact_information' => 'new contact information', 'address' => 'new address' }

    assert_redirected_to :action => 'index'
  end

  should 'not permmit if not logged' do
    logout
    person = create_user('test_user')
    get :index, :profile => 'test_user'
  end

  should 'display categories to choose to associate profile' do
    cat1 = Environment.default.categories.build(:name => 'top category'); cat1.save!
    cat2 = Environment.default.categories.build(:name => 'sub category', :parent => cat1); cat2.save!
    person = create_user('test_user').person
    get :edit_categories, :profile => 'test_user'
    assert_response :success
    assert_template 'edit_categories'
    assert_tag :tag => 'input', :attributes => {:name => 'profile_object[category_ids][]'}
  end

  should 'save categorization of profile' do
    cat1 = Environment.default.categories.build(:name => 'top category'); cat1.save!
    cat2 = Environment.default.categories.build(:name => 'sub category', :parent => cat1); cat2.save!
    person = create_user('test_user').person
    post :edit_categories, :profile => 'test_user', :profile_object => {:category_ids => [cat2.id]}
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
    assert_tag :tag => 'input', :attributes => { :type => 'checkbox', :checked => 'checked', :name => 'profile_data[public_profile]', :value => 'true' }
    assert_tag :tag => 'input', :attributes => { :type => 'hidden', :name => 'profile_data[public_profile]', :value => false }
  end

  should 'save profile publication option set to true' do
    post :edit, :profile => 'ze', :profile_data => { :public_profile => 'true' }
    assert_equal true, Profile['ze'].public_profile
  end

  should 'save profile publication option set to false' do
    post :edit, :profile => 'ze', :profile_data => { :public_profile => 'false' }
    assert_equal false, Profile['ze'].public_profile
  end

  should 'show error messages for'

  should 'edit enterprise' do
    ent = Enterprise.create!(:name => 'test org', :identifier => 'testent')
    get :edit, :profile => 'testent'
    assert_response :success
  end

end
