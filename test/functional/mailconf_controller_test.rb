require File.dirname(__FILE__) + '/../test_helper'

class MailconfControllerTest < ActionController::TestCase

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
    login_as('ze')
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
      :tag => 'a',
      :content => 'Enable e-Mail',
      :attributes => {:href => '/myprofile/ze/mailconf/enable'}
    )
  end

  should 'display correctly the state false of e-mail enable/disable' do
    login_as('ze')
    users(:ze).update_attributes!(:enable_email => false)
    get :index, :profile => 'ze'
    assert_tag :tag => 'a', :content => 'Enable e-Mail'
    assert_no_tag :tag => 'a', :content => 'Disable e-Mail', :attributes => { :href => '/myprofile/ze/mailconf/disable' }
  end

  should 'not display www in email address when force_www=true' do
    login_as('ze')
    env = Environment.default
    env.force_www = true
    env.save!
    get :index, :profile => 'ze'
    assert_tag :tag => 'li', :content => /ze@colivre.net/
  end

  should 'not display www in email address when force_www=false' do
    login_as('ze')
    env = Environment.default
    env.force_www = false
    env.save!
    get :index, :profile => 'ze'
    assert_tag :tag => 'li', :content => /ze@colivre.net/
  end

  should 'create task to environment admin when enable email' do
    login_as('ze')
    assert_difference EmailActivation, :count do
      post :enable, :profile => 'ze'
    end
  end

  should 'save mail enable/disable as false' do
    login_as('ze')
    assert users(:ze).enable_email!
    post :disable, :profile => 'ze'
    assert !Profile['ze'].user.enable_email
  end

  should 'go back on save' do
    login_as('ze')
    post :enable, :profile => 'ze'
    assert_redirected_to :controller => 'profile_editor'
  end

  should 'go to profile editor after enable email' do
    login_as('ze')
    post :enable, :profile => 'ze'
    assert_redirected_to :controller => 'profile_editor', :action => 'edit'
  end

  should 'display notice after saving' do
    login_as('ze')
    post :enable, :profile => 'ze'
    assert_kind_of String, session[:notice]
  end

  should 'link back to control panel' do
    login_as('ze')
    get :index, :profile => 'ze'
    assert_tag :tag => 'div', :attributes => { :id => 'content'}, :descendant => { :tag => 'a', :attributes => { :href => '/myprofile/ze' } }
  end

  should 'not display input for enable/disable e-mail when has pending_enable_email' do
    login_as('ze')
    users(:ze).update_attribute(:environment_id, Environment.default.id)
    EmailActivation.create!(:requestor => users(:ze).person, :target => Environment.default)
    get :index, :profile => 'ze'
    assert_no_tag :tag => 'input', :attributes => {:name => 'user[enable_email]', :type => 'checkbox'}
  end

end
