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
    t = AddMember.create!(:person => profile, :organization => profile)
    count = profile.members.size
    post :close, :decision => 'finish', :id => t.id
    profile = Profile.find(@profile.id)
    assert_equal count + 1, profile.members.size
  end

  should 'display custom form to add members task' do
    t = AddMember.create!(:person => profile, :organization => profile)
    get :index, :profile => profile.identifier
    assert_tag :tag => 'form', :attributes => { :action => "/myprofile/#{profile.identifier}/tasks/close/#{t.id}" }
  end

  should 'display member role checked if target has members' do
    profile.affiliate(profile, Profile::Roles.admin(profile.environment.id))
    assert_equal 1, profile.members.size
    t = AddMember.create!(:person => profile, :organization => profile)
    get :index, :profile => profile.identifier
    assert_tag :tag => 'input', :attributes => { :name => 'task[roles][]', :checked => 'checked', :value => Profile::Roles.member(profile.environment.id).id }
  end

  should 'display roles besides role member unchecked if target has members' do
    profile.affiliate(profile, Profile::Roles.admin(profile.environment.id))
    assert_equal 1, profile.members.size
    t = AddMember.create!(:person => profile, :organization => profile)
    get :index, :profile => profile.identifier
    Role.find(:all).select{ |r| r.has_kind?('Profile') and r.id != Profile::Roles.member(profile.environment.id).id }.each do |i|
      assert_no_tag :tag => 'input', :attributes => { :name => 'task[roles][]', :checked => 'checked', :value => i.id }
    end
  end

  should 'display all roles checked if target has no members' do
    assert_equal 0, profile.members.size
    t = AddMember.create!(:person => profile, :organization => profile)
    get :index, :profile => profile.identifier
    Role.find(:all).select{ |r| r.has_kind?('Profile') }.each do |i|
      assert_tag :tag => 'input', :attributes => { :name => 'task[roles][]', :checked => 'checked', :value => i.id }
    end
  end

  should 'display a create ticket form' do
    get :new, :profile => profile.identifier

    assert_template 'new'
  end

  should 'add a hidden field with target_id when informed in the URL' do
    friend = create_user('myfriend').person
    profile.add_friend(friend)

    get :new, :profile => profile.identifier, :target_id => friend.id.to_s

    assert_tag :tag => 'input', :attributes => { :type => 'hidden', :name => 'ticket[target_id]', :value => friend.id }
  end

  should 'select friend from list when not already informed' do
    get :new, :profile => profile.identifier
    assert_tag :tag => 'select', :attributes => { :name =>  'ticket[target_id]' }
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

  should 'set target of ticket when creating it' do
     f = create_user('friend').person
     profile.add_friend f

     post :new, :profile => profile.identifier, :ticket => {:title => 'test ticket', :target_id => f.id, :target_type => 'Profile'}
     assert_response :redirect

     assert_equal f, assigns(:ticket).target
  end

  should 'create published article after finish approve article task' do
    PublishedArticle.destroy_all
    c = Community.create!(:name => 'test comm', :moderated_articles => false)
    @controller.stubs(:profile).returns(c)
    c.affiliate(profile, Profile::Roles.all_roles(profile.environment.id))
    article = profile.articles.create!(:name => 'something interesting', :body => 'ruby on rails')
    t = ApproveArticle.create!(:name => 'test name', :article => article, :target => c, :requestor => profile)

    post :close, :decision => 'finish', :id => t.id, :task => { :name => 'new_name'}
    assert_equal article, PublishedArticle.find(:first).reference_article
  end

  should 'create published article in folder after finish approve article task' do
    PublishedArticle.destroy_all
    c = Community.create!(:name => 'test comm', :moderated_articles => false)
    @controller.stubs(:profile).returns(c)
    folder = c.articles.create!(:name => 'test folder', :type => 'Folder')
    c.affiliate(profile, Profile::Roles.all_roles(profile.environment.id))
    article = profile.articles.create!(:name => 'something interesting', :body => 'ruby on rails')
    t = ApproveArticle.create!(:name => 'test name', :article => article, :target => c, :requestor => profile)

    post :close, :decision => 'finish', :id => t.id, :task => { :name => 'new_name', :article_parent_id => folder.id}
    assert_equal folder, PublishedArticle.find(:first).parent
  end

  should 'be highlighted if asked when approving a published article' do
    PublishedArticle.destroy_all
    c = Community.create!(:name => 'test comm', :moderated_articles => false)
    @controller.stubs(:profile).returns(c)
    folder = c.articles.create!(:name => 'test folder', :type => 'Folder')
    c.affiliate(profile, Profile::Roles.all_roles(profile.environment.id))
    article = profile.articles.create!(:name => 'something interesting', :body => 'ruby on rails')
    t = ApproveArticle.create!(:name => 'test name', :article => article, :target => c, :requestor => profile)

    post :close, :decision => 'finish', :id => t.id, :task => { :name => 'new_name', :article_parent_id => folder.id, :highlighted => true}
    assert_equal true, PublishedArticle.find(:first).highlighted
  end

end
