require File.dirname(__FILE__) + '/../test_helper'
require 'friends_controller'

class FriendsController; def rescue_action(e) raise e end; end

class FriendsControllerTest < Test::Unit::TestCase

  include NoosferoTest

  def self.extra_parameters
    { :profile => 'testuser' }
  end

  def setup
    @controller = FriendsController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new

    self.profile = create_user('testuser').person
    self.friend = create_user('thefriend').person
  end
  attr_accessor :profile, :friend

  should 'confirm addition of new friend' do
    get :add, :id => friend.id

    assert_response :success
    assert_template 'add'

    ok("must load the friend being added to display") { friend == assigns(:friend) } 

  end

  should 'actually add friend' do
    assert_difference AddFriend, :count do
      post :add, :id => friend.id, :confirmation => '1'
      assert_response :redirect
    end
  end

end
