# encoding: UTF-8
require_relative "../test_helper"
require 'contact_controller'

# Re-raise errors caught by the controller.
class ContactController; def rescue_action(e) raise e end; end

class ContactControllerTest < ActionController::TestCase

  all_fixtures

  def setup
    @controller = ContactController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new

    @profile = create_user('contact_test_user').person
    @enterprise = fast_create(Enterprise, :identifier => 'contact_test_enterprise', :name => 'Test contact enteprise')

    login_as('contact_test_user')
  end
  attr_reader :profile, :enterprise

  should 'respond to new' do
    get :new, :profile => enterprise.identifier
    assert_response :success
  end

  should 'display destinatary name in title if profile is a person' do
    get :new, :profile => profile.identifier
    assert_tag :tag => 'h1', :content => /Send.*#{profile.name}/
  end

  should 'display administrators in title if profile is an organization' do
    get :new, :profile => enterprise.identifier
    assert_tag :tag => 'h1', :content => /Send.*administrators/
  end

  should 'display profile name in tooltip if profile is an organization' do
    get :new, :profile => enterprise.identifier
    assert_tag :tag => 'div', :content => /administrators.*#{enterprise.name}/, :attributes => {:class => 'tooltip'}
  end

  should 'not display tooltip if profile is a person' do
    get :new, :profile => profile.identifier
    assert_no_tag :tag => 'div', :attributes => {:class => 'tooltip'}
  end

  should 'add form to create contact via post' do
    get :new, :profile => enterprise.identifier
    assert_tag :tag => 'form', :attributes => { :action => "/contact/#{enterprise.identifier}/new", :method => 'post' }
  end

  should 'display input for message' do
    get :new, :profile => enterprise.identifier
    assert_tag :tag => 'textarea', :attributes => { :name => 'contact[message]' }
  end

  should 'have logged user email' do
    get :new, :profile => enterprise.identifier
    assert_equal profile.email, assigns(:contact).email
  end

  should 'have logged user name' do
    get :new, :profile => enterprise.identifier
    assert_equal profile.name, assigns(:contact).name
  end

  should 'display checkbox for receive copy of email' do
    get :new, :profile => enterprise.identifier
    assert_tag :tag => 'input', :attributes => {:name => 'contact[receive_a_copy]'}
  end

  should 'not throws exception when city and state is blank' do
    State.expects(:exists?).with('').never
    City.expects(:exists?).with('').never
    assert_nothing_raised do
      post :new, :profile => enterprise.identifier, :contact => {:subject => 'Hi', :message => 'Hi, all', :state => '', :city => ''}
    end
  end

  should 'not display select/city select when disable it in environment' do
    state = State.create!(:name => "Bahia", :environment => Environment.default)
    get :new, :profile => profile.identifier
    assert_tag :tag => 'select', :attributes => {:name => 'state'}
    env = Environment.default
    env.enable('disable_select_city_for_contact')
    env.save!
    get :new, :profile => profile.identifier
    assert_no_tag :tag => 'select', :attributes => {:name => 'state'}
  end

  should 'show name, email and captcha if not logged' do
    logout
    get :new, :profile => profile.identifier
    assert_tag :tag => 'input', :attributes => {:name => 'contact[name]'}
    assert_tag :tag => 'input', :attributes => {:name => 'contact[email]'}
    assert_tag :attributes => {id: 'dynamic_recaptcha'}
  end

  should 'identify sender' do
    post :new, :profile => enterprise.identifier, :contact => {:subject => 'Hi', :message => 'Hi, all', :state => '', :city => ''}
    assert_equal Person['contact_test_user'], assigns(:contact).sender
  end

  should 'deliver contact if subject and message are filled' do
    post :new, :profile => enterprise.identifier, :contact => {:subject => 'Hi', :message => 'Hi, all'}, :confirm => 'true'
    assert_response :redirect
    assert_redirected_to :action => 'new'
  end

  should 'redirect back to contact page after send contact' do
    post :new, :profile => enterprise.identifier, :contact => {:subject => 'Hi', :message => 'Hi, all'}, :confirm => 'true'
    assert_response :redirect
    assert_redirected_to :action => 'new'
  end

  should 'define city and state for contact object' do
    City.stubs(:exists?).returns(true)
    City.stubs(:find).returns(City.new(:name => 'Camaçari'))
    State.stubs(:exists?).returns(true)
    State.stubs(:find).returns(State.new(:name => 'Bahia'))
    post :new, :profile => enterprise.identifier, :contact => {:subject => 'Hi', :message => 'Hi, all'}, :state => '1', :city => '1', :confirm => 'true'
    assert_equal 'Camaçari', assigns(:contact).city
    assert_equal 'Bahia', assigns(:contact).state
  end

  should 'not show send e-mail page to non members of private community' do
    community = fast_create(Community, :identifier => 'private-community', :name => 'Private Community', :public_profile => false)

    post :new, :profile => community.identifier

    assert_response :forbidden
    assert_template "profile/_private_profile"
  end

  should 'not show send e-mail page to non members of invisible community' do
    community = fast_create(Community, :identifier => 'invisible-community', :name => 'Private Community', :visible => false)

    post :new, :profile => community.identifier

    assert_response :forbidden
    assert_template :access_denied
  end

  should 'show send e-mail page to members of private community' do
    community = fast_create(Community, :identifier => 'private-community', :name => 'Private Community', :public_profile => false)
    community.add_member(@profile)

    post :new, :profile => community.identifier

    assert_response :success
  end

end
