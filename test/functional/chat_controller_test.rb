require_relative "../test_helper"

class ChatControllerTest < ActionController::TestCase

  def setup
    env = Environment.default
    env.enable('xmpp_chat')
    env.save!
    #TODO Maybe someday we should have a real testing ejabberd server
    RubyBOSH.stubs(:initialize_session).returns(['fake-jid@example.org', 'fake-sid', 'fake-rid'])
    @person = create_user('testuser').person
  end

  should 'cant view chat when not logged in' do
    get :start_session
    assert_response 302
  end

  should 'can view chat when logged in' do
    login_as 'testuser'

    get :start_session
    assert_response :success
  end

  should 'get default avatar' do
    login_as 'testuser'

    get :avatar, :id => 'testuser'

    assert_response :redirect
  end

  should 'get avatar from community' do
    community = fast_create(Community)
    login_as 'testuser'

    get :avatar, :id => community.identifier

    assert_equal 'image/png', @response.content_type
    assert @response.body.index('PNG')
  end

  begin
    require 'ruby_bosh'
    should 'try to start xmpp session' do
      login_as 'testuser'

      RubyBOSH.expects(:initialize_session).raises("Error trying to connect...")

      get :start_session
      assert_response 500
      assert_template 'start_session_error'
    end
  rescue LoadError
    puts 'W: could not load RubyBOSH; skipping some chat tests'
    should 'skip the above test if the chat dependencies are not installed' do
      print '*'
    end
  end

  should 'render not found if chat feature disabled' do
    login_as 'testuser'

    env = Environment.default
    env.disable('xmpp_chat')
    env.save!

    get :start_session

    assert_response 404
    assert_template 'not_found'
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

  should 'toggle chat status' do
    login_as 'testuser'

    get :start_session
    assert_nil session[:chat][:status]

    get :toggle
    assert_equal 'opened', session[:chat][:status]

    get :toggle
    assert_equal 'closed', session[:chat][:status]

    get :toggle
    assert_equal 'opened', session[:chat][:status]
  end

  should 'set tab' do
    login_as 'testuser'
    get :start_session

    post :tab, :tab_id => 'my_tab'
    assert_equal 'my_tab', session[:chat][:tab_id]
  end

  should 'join room' do
    login_as 'testuser'
    get :start_session

    post :join, :room_id => 'room1'
    assert_equivalent ['room1'], session[:chat][:rooms]

    post :join, :room_id => 'room2'
    assert_equivalent ['room1', 'room2'], session[:chat][:rooms]

    post :join, :room_id => 'room1'
    assert_equivalent ['room1', 'room2'], session[:chat][:rooms]
  end

  should 'leave room' do
    login_as 'testuser'
    get :start_session
    session[:chat][:rooms] = ['room1', 'room2']

    post :leave, :room_id => 'room2'
    assert_equivalent ['room1'], session[:chat][:rooms]

    post :leave, :room_id => 'room1'
    assert_equivalent [], session[:chat][:rooms]

    post :leave, :room_id => 'room1'
    assert_equivalent [], session[:chat][:rooms]
  end

  should 'fetch chat session as json' do
    login_as 'testuser'
    get :start_session
    my_chat = {:status => 'opened', :rooms => ['room1', 'room2'], :tab_id => 'room1'}
    session[:chat] = my_chat

    get :my_session
    assert_equal @response.body, my_chat.to_json
  end

end
