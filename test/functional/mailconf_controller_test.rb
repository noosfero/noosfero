require File.dirname(__FILE__) + '/../test_helper'

class MailconfControllerTest < Test::Unit::TestCase

  all_fixtures

  def setup
    @controller = MailconfController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new

    MailConf.stubs(:enabled?).returns(true)
    MailConf.stubs(:webmail_url).returns('http://web.mail.net/')
  end

  should 'check if mail is enabled' do
    MailConf.expects(:enabled?).returns(false)

    login_as('ze')
    get :index, :profile => 'ze'
    assert_response 500
  end

  should 'not be used by organizations' do
    org = Organization.create!(:name => 'testorg', :identifier => 'testorg')
    get :index, :profile => 'testorg'
    assert_response 403
  end

  should 'not be edited by others' do
    login_as('johndoe')
    get :index, :profile => 'ze'
    assert_response 403
  end

  should 'be edited by owner' do
    login_as('ze')
    get :index, :profile => 'ze'
    assert_response :success
  end

  should 'expose user to templates' do
    login_as('ze')
    get :index, :profile => 'ze'
    assert_equal users(:ze), assigns(:user)
  end

  should 'present enable/disable for e-mail use'  do
    login_as('ze')
    get :index, :profile => 'ze'
    assert_tag(
      :tag => 'form',
      :attributes => { :action => '/myprofile/ze/mailconf/save'},
      :descendant => {
        :tag => 'input',
        :attributes => { :name => 'user[enable_email]', :type => 'checkbox' }
      }
    )
  end

  should 'display correctly the state true of e-mail enable/disable' do
    login_as('ze')
    users(:ze).update_attributes!(:enable_email => true)
    get :index, :profile => 'ze'
    assert_tag :tag => 'input', :attributes => { :name => 'user[enable_email]', :type => 'checkbox', :value => '1', :checked => 'checked' }
  end

  should 'display correctly the state false of e-mail enable/disable' do
    login_as('ze')
    users(:ze).update_attributes!(:enable_email => false)
    get :index, :profile => 'ze'
    assert_no_tag :tag => 'input', :attributes => { :name => 'user[enable_email]', :type => 'checkbox', :value => '1', :checked => 'checked' }
    assert_tag :tag => 'input', :attributes => { :name => 'user[enable_email]', :type => 'hidden', :value => '0' }
  end

  should 'save mail enable/disable as true' do
    login_as('ze')
    post :save, :profile => 'ze', :user => { :enable_email => '1' }
    assert Profile['ze'].user.enable_email
  end

  should 'save mail enable/disable as false' do
    login_as('ze')
    post :save, :profile => 'ze', :user => { :enable_email => '0' }
    assert !Profile['ze'].user.enable_email
  end

  should 'go back on save' do
    login_as('ze')
    post :save, :profile => 'ze'
    assert_redirected_to :action => 'index'
  end

  should 'display notice after saving' do
    login_as('ze')
    post :save, :profile => 'ze'
    assert_kind_of String, flash[:notice]
  end

  should 'link back to control panel' do
    login_as('ze')
    get :index, :profile => 'ze'
    assert_tag :tag => 'div', :attributes => { :id => 'content'}, :descendant => { :tag => 'a', :attributes => { :href => '/myprofile/ze' } }
  end

end
