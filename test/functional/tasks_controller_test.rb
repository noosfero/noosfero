require File.dirname(__FILE__) + '/../test_helper'
require 'tasks_controller'

class TasksController; def rescue_action(e) raise e end; end

class TasksControllerTest < Test::Unit::TestCase

  noosfero_test :profile => 'testuser' 

  def setup
    @controller = TasksController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new

    self.profile = create_user('testuser').person
    @controller.stubs(:profile).returns(profile)
  end
  attr_accessor :profile

  should 'list pending tasks' do
    get :index

    assert_response :success
    assert_template 'index'
    assert_kind_of Array, assigns(:tasks)
  end

  should 'list processed tasks' do
    get :processed

    assert_response :success
    assert_template 'processed'
    assert_kind_of Array, assigns(:tasks)
  end

  should 'be able to finish a task' do
    t = profile.tasks.build; t.save!

    post :close, :decision => 'finish', :id => t.id
    assert_redirected_to :action => 'index'

    t.reload
    ok('task should be finished') { t.status == Task::Status::FINISHED }
  end

  should 'be able to cancel a task' do
    t = profile.tasks.build; t.save!

    post :close, :decision => 'cancel', :id => t.id
    assert_redirected_to :action => 'index'

    t.reload
    ok('task should be cancelled') { t.status == Task::Status::CANCELLED }
  end

end
