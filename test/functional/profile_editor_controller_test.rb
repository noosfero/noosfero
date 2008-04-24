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
    assert_local_files_reference
  end
  
  def test_valid_xhtml
    assert_valid_xhtml
  end
  
  def test_index
    person = User.create(:login => 'test_profile', :email => 'test@noosfero.org', :password => 'test', :password_confirmation => 'test').person
    person.person_info.name = 'a test profile'
    person.person_info.address = 'my address'
    person.person_info.contact_information = 'my contact information'
    person.person_info.save

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
    assert_template 'person_info'
    assert_response :success
    assert_template 'person_info'
  end

  def test_saving_profile_info 
    person = User.create(:login => 'test_profile', :email => 'test@noosfero.org', :password => 'test', :password_confirmation => 'test').person
    person.person_info.address = 'my address'
    person.person_info.contact_information = 'my contact information'
    person.person_info.save
    
#    profile.person_info.expects(:update_attributes).with({ 'contact_information' => 'new contact information', 'address' => 'new address' }).returns(true)
    post :edit, :profile => 'test_profile', :info => { 'contact_information' => 'new contact information', 'address' => 'new address' }

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
    post :edit, :profile => person.identifier, :info => { :name => name }
    assert_sanitized assigns(:profile).info.name
  end

  should 'filter html from contact_person to organization' do
    org = Organization.create!(:name => 'test org', :identifier => 'testorg')
    contact = "name <strong id='name_html_test'>with</strong> html"
    post :edit, :profile => org.identifier, :info => { :contact_person => contact }
    assert_sanitized assigns(:profile).info.contact_person
  end

  should 'filter html from acronym organization' do
    org = Organization.create!(:name => 'test org', :identifier => 'testorg')
    value = "name <strong id='name_html_test'>with</strong> html"
    post :edit, :profile => org.identifier, :info => { :acronym => value }
    assert_sanitized assigns(:profile).info.acronym
  end

  should 'filter html from legal_form organization' do
    org = Organization.create!(:name => 'test org', :identifier => 'testorg')
    value = "name <strong id='name_html_test'>with</strong> html"
    post :edit, :profile => org.identifier, :info => { :legal_form => value }
    assert_sanitized assigns(:profile).info.legal_form
  end

  should 'filter html from economic_activity organization' do
    org = Organization.create!(:name => 'test org', :identifier => 'testorg')
    value = "name <strong id='name_html_test'>with</strong> html"
    post :edit, :profile => org.identifier, :info => { :economic_activity => value }
    assert_sanitized assigns(:profile).info.economic_activity
  end

  should 'filter html from management_information organization' do
    org = Organization.create!(:name => 'test org', :identifier => 'testorg')
    value = "name <strong id='name_html_test'>with</strong> html"
    post :edit, :profile => org.identifier, :info => { :management_information => value }
    assert_sanitized assigns(:profile).info.management_information
  end

end
