require File.dirname(__FILE__) + '/../test_helper'

class ChatControllerTest < ActionController::TestCase

  def setup
    env = Environment.default
    env.enable('xmpp_chat')
    env.save!
  end

  should 'cant view chat when not logged in' do
    get :index
    assert_response 302
  end

  should 'can view chat when logged in' do
    create_user('testuser').person
    login_as 'testuser'

    get :index
    assert_response :success
  end

  should 'get default avatar' do
    create_user('testuser').person
    login_as 'testuser'

    get :avatar, :id => 'testuser'

    assert_equal 'image/png', @response.content_type
    assert_match /PNG/, @response.body
  end

  should 'not auto connect if last presence status is blank' do
    create_user('testuser')
    login_as 'testuser'

    get :index
    assert_template 'chat'
  end

  should 'auto connect if there last presence status was chat' do
    user = create_user('testuser', :last_presence_status => 'chat')
    login_as 'testuser'

    get :index
    assert_template 'auto_connect_online'
  end

  should 'auto connect busy if last presence status was dnd' do
    user = create_user('testuser', :last_presence_status => 'dnd')
    login_as 'testuser'

    get :index
    assert_template 'auto_connect_busy'
  end

  should 'try to start xmpp session' do
    user = create_user('testuser')
    login_as 'testuser'

    RubyBOSH.expects(:initialize_session).raises("Erro trying to connect...")

    get :start_session
    assert_response 500
    assert_template 'start_session_error'
  end

  should 'render not found if chat feature disabled' do
    user = create_user('testuser')
    login_as 'testuser'

    env = Environment.default
    env.disable('xmpp_chat')
    env.save!

    get :index

    assert_response 404
    assert_template 'not_found.rhtml'
  end

end
