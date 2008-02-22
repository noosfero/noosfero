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
  end
  attr_accessor :profile

  should 'list pending tasks' do
    get :index

    assert_response :success
    assert_template 'index'
    assert_kind_of Array, assigns(:tasks)
  end

  should 'display form for resolving a task'

  should 'be able to finish a task'

  should 'be able to cancel a task'

end
