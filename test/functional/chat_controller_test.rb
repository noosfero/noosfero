require File.dirname(__FILE__) + '/../test_helper'

class ChatControllerTest < ActionController::TestCase

  def setup
    env = Environment.default
    env.enable('xmpp_chat')
    env.save!
    @person = create_user('testuser').person
  end

  should 'cant view chat when not logged in' do
    get :index
    assert_response 302
  end

  should 'can view chat when logged in' do
    login_as 'testuser'

    get :index
    assert_response :success
  end

  should 'get default avatar' do
    login_as 'testuser'

    get :avatar, :id => 'testuser'

    assert_equal 'image/png', @response.content_type
    assert_match /PNG/, @response.body
  end

  should 'get avatar from community' do
    community = fast_create(Community)
    login_as 'testuser'

    get :avatar, :id => community.identifier

    assert_equal 'image/png', @response.content_type
    assert_match /PNG/, @response.body
  end

  should 'auto connect if last presence status is blank' do
    login_as 'testuser'

    get :index
    assert_template 'auto_connect_online'
  end

  should 'auto connect if there last presence status was chat' do
    create_user('testuser_online', :last_chat_status => 'chat')
    login_as 'testuser_online'

    get :index
    assert_template 'auto_connect_online'
  end

  should 'auto connect busy if last presence status was dnd' do
    create_user('testuser_busy', :last_chat_status => 'dnd')
    login_as 'testuser_busy'

    get :index
    assert_template 'auto_connect_busy'
  end

  should 'try to start xmpp session' do
    login_as 'testuser'

    RubyBOSH.expects(:initialize_session).raises("Error trying to connect...")

    get :start_session
    assert_response 500
    assert_template 'start_session_error'
  end

  should 'render not found if chat feature disabled' do
    login_as 'testuser'

    env = Environment.default
    env.disable('xmpp_chat')
    env.save!

    get :index

    assert_response 404
    assert_template 'not_found.rhtml'
  end

  should 'not update presence status from non-ajax requests' do
    @person.user.expects(:update_attributes).never
    @controller.stubs(:current_user).returns(@person.user)
    get :update_presence_status
    assert_template nil
  end

  should 'update presence status from ajax requests' do
    @person.user.expects(:update_attributes).once
    @controller.stubs(:current_user).returns(@person.user)
    @request.stubs(:xhr?).returns(true)
    get :update_presence_status
    assert_template nil
  end

  should 'update presence status time from ajax requests' do
    @controller.stubs(:current_user).returns(@person.user)
    @request.stubs(:xhr?).returns(true)
    chat_status_at = @person.user.chat_status_at
    get :update_presence_status
    assert_not_equal chat_status_at, @person.user.chat_status_at
  end

end
