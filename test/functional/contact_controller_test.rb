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

  should 'add hidden field with target_id' do
    get :new, :profile => enterprise.identifier
    assert_tag :tag => 'input', :attributes => { :name => 'contact[target_id]', :value => enterprise.id, :type => 'hidden' }
  end

  should 'add requestor id if logged in' do
    login_as(profile.identifier)
    @controller.stubs(:current_user).returns(profile.user)
    get :new, :profile => enterprise.identifier
    assert_tag :tag => 'input', :attributes => { :name => 'contact[requestor_id]', :value => profile.id }
  end

  should 'nil requestor id if not logged in' do
    get :new, :profile => enterprise.identifier
    assert_tag :tag => 'input', :attributes => { :name => 'contact[requestor_id]', :value => nil }
  end

  should 'redirect to profile page after contact' do
    post :new, :profile => enterprise.identifier, :contact => {:subject => 'Hi', :email => 'visitor@mail.invalid', :message => 'Hi, all', :target_id => enterprise.id}
    assert_response :redirect
    assert_redirected_to :controller => 'profile', :profile => enterprise.identifier
  end

  should 'be able to send contact' do
    assert_difference Contact, :count do
      post :new, :profile => enterprise.identifier, :contact => {:subject => 'Hi', :email => 'visitor@mail.invalid', :message => 'Hi, all', :target_id => enterprise.id}
    end
  end

end
