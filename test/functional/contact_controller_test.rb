require File.dirname(__FILE__) + '/../test_helper'
require 'contact_controller'

# Re-raise errors caught by the controller.
class ContactController; def rescue_action(e) raise e end; end

class ContactControllerTest < Test::Unit::TestCase

  all_fixtures

  def setup
    @controller = ContactController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new

    @profile = create_user('contact_test_user').person
    @enterprise = Enterprise.create!(:identifier => 'contact_test_enterprise', :name => 'Test contact enteprise')
  end
  attr_reader :profile, :enterprise

  should 'respond to new' do
    get :new, :profile => enterprise.identifier
    assert_response :success
  end

  should 'display destinatary name in title' do
    get :new, :profile => enterprise.identifier
    assert_tag :tag => 'h1', :content => "Contact #{enterprise.name}"
  end

  should 'add form to create contact via post' do
    get :new, :profile => enterprise.identifier
    assert_tag :tag => 'form', :attributes => { :action => "/contact/#{enterprise.identifier}/new", :method => 'post' }
  end

  should 'display input for destinatary email' do
    get :new, :profile => enterprise.identifier
    assert_tag :tag => 'input', :attributes => { :name => 'contact[email]', :type => 'text' }
  end

  should 'display input for message' do
    get :new, :profile => enterprise.identifier
    assert_tag :tag => 'textarea', :attributes => { :name => 'contact[message]' }
  end

  should 'redirect back to contact page after send contact' do
    post :new, :profile => enterprise.identifier, :contact => {:name => 'john', :subject => 'Hi', :email => 'visitor@mail.invalid', :message => 'Hi, all'}
    assert_response :redirect
    assert_redirected_to :action => 'new'
  end

  should 'fill email if user logged in' do
    login_as(profile.identifier)
    get :new, :profile => enterprise.identifier
    assert_tag :tag => 'input', :attributes => {:name => 'contact[email]', :value => profile.email}
  end

  should 'fill name if user logged in' do
    login_as(profile.identifier)
    get :new, :profile => enterprise.identifier
    assert_tag :tag => 'input', :attributes => {:name => 'contact[name]', :value => profile.name}
  end

  should 'define city and state' do
    City.stubs(:find).returns(City.new(:name => 'Camaçari'))
    State.stubs(:find).returns(State.new(:name => 'Bahia'))
    post :new, :profile => enterprise.identifier, :contact => {:name => 'john', :subject => 'Hi', :email => 'visitor@mail.invalid', :message => 'Hi, all', :state => 1, :city => 1}
    assert_equal 'Camaçari', assigns(:contact).city
    assert_equal 'Bahia', assigns(:contact).state
  end

  should 'display checkbox for receive copy of email' do
    get :new, :profile => enterprise.identifier
    assert_tag :tag => 'input', :attributes => {:name => 'contact[receive_a_copy]'}
  end

end
