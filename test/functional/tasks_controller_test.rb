require File.dirname(__FILE__) + '/../test_helper'
require 'tasks_controller'

class TasksController; def rescue_action(e) raise e end; end

class TasksControllerTest < Test::Unit::TestCase

  noosfero_test :profile => 'testuser' 

  def setup
    @controller = TasksController.new
    @request    = ActionController::TestRequest.new
    @request.stubs(:ssl?).returns(true)
    @response   = ActionController::TestResponse.new

    self.profile = create_user('testuser').person
    @controller.stubs(:profile).returns(profile)
    login_as 'testuser'
  end
  attr_accessor :profile

  def test_local_files_reference
    assert_local_files_reference
  end
  
  def test_valid_xhtml
    assert_valid_xhtml
  end
  
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

  should 'affiliate roles to user after finish add member task' do
    t = AddMember.create!(:person => profile, :community => profile)
    count = profile.members.size
    post :close, :decision => 'finish', :id => t.id
    profile.reload
    assert_equal count + 1, profile.members.size
  end

  should 'display custom form to add members task' do
    t = AddMember.create!(:person => profile, :community => profile)
    get :index, :profile => profile.identifier
    assert_tag :tag => 'form', :attributes => { :action => "/myprofile/#{profile.identifier}/tasks/close/#{t.id}" }
  end

  should 'display member role checked if target has members' do
    profile.affiliate(profile, Profile::Roles.admin)
    assert_equal 1, profile.members.size
    t = AddMember.create!(:person => profile, :community => profile)
    get :index, :profile => profile.identifier
    assert_tag :tag => 'input', :attributes => { :name => 'task[roles][]', :checked => 'checked', :value => Profile::Roles.member.id }
  end

  should 'display roles besides role member unchecked if target has members' do
    profile.affiliate(profile, Profile::Roles.admin)
    assert_equal 1, profile.members.size
    t = AddMember.create!(:person => profile, :community => profile)
    get :index, :profile => profile.identifier
    Role.find(:all).select{ |r| r.has_kind?('Profile') and r.id != Profile::Roles.member.id }.each do |i|
      assert_no_tag :tag => 'input', :attributes => { :name => 'task[roles][]', :checked => 'checked', :value => i.id }
    end
  end

  should 'display all roles checked if target has no members' do
    assert_equal 0, profile.members.size
    t = AddMember.create!(:person => profile, :community => profile)
    get :index, :profile => profile.identifier
    Role.find(:all).select{ |r| r.has_kind?('Profile') }.each do |i|
      assert_tag :tag => 'input', :attributes => { :name => 'task[roles][]', :checked => 'checked', :value => i.id }
    end
  end

  should 'display a create ticket form' do
    get :new, :profile => profile.identifier

    assert_template 'new'
  end

  should 'create a ticket' do
    assert_difference Ticket, :count do
      post :new, :profile => profile.identifier, :ticket => {:title => 'test ticket'}
    end
  end

  should 'create a ticket with profile requestor' do
    post :new, :profile => profile.identifier, :ticket => {:title => 'new task'} 
    
    assert_equal profile, assigns(:ticket).requestor
  end

  should 'list tasks that this profile created' do
    task = Ticket.create!(:title => 'test', :requestor => profile)
    get :list_requested, :profile => profile.identifier

    assert_includes assigns(:tasks), task
  end
end
