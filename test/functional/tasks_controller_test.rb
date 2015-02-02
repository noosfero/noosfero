require_relative "../test_helper"
require 'tasks_controller'

class TasksController; def rescue_action(e) raise e end; end

class TasksControllerTest < ActionController::TestCase

  noosfero_test :profile => 'testuser' 

  def setup
    @controller = TasksController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new

    self.profile = create_user('testuser').person
    @controller.stubs(:profile).returns(profile)
    login_as 'testuser'
  end
  attr_accessor :profile

  def assert_redirected_to(options)
    super({ :controller => 'tasks', :profile => profile.identifier }.merge(options))
  end

  should 'list pending tasks' do
    get :index

    assert_response :success
    assert_template 'index'
    assert assigns(:tasks)
  end

  should 'list pending tasks without spam' do
    requestor = fast_create(Person)
    task_spam = Task.create!(:requestor => requestor, :target => profile, :spam => true)
    task_ham = Task.create!(:requestor => requestor, :target => profile, :spam => false)

    get :index
    assert_response :success
    assert_includes assigns(:tasks), task_ham
    assert_not_includes assigns(:tasks), task_spam
  end

  should 'list processed tasks' do
    get :processed

    assert_response :success
    assert_template 'processed'
    assert_kind_of Array, assigns(:tasks)
  end

  should 'list processed tasks without spam' do
    requestor = fast_create(Person)
    task_spam = create(Task, :status => Task::Status::FINISHED, :requestor => requestor, :target => profile, :spam => true)
    task_ham = create(Task, :status => Task::Status::FINISHED, :requestor => requestor, :target => profile, :spam => false)

    get :processed
    assert_response :success
    assert_includes assigns(:tasks), task_ham
    assert_not_includes assigns(:tasks), task_spam
  end

  should 'be able to finish a task' do
    t = profile.tasks.build; t.save!

    post :close, :tasks => {t.id => {:decision => 'finish', :task => {}}}
    assert_redirected_to :action => 'index'

    t.reload
    ok('task should be finished') { t.status == Task::Status::FINISHED }
  end

  should 'be able to cancel a task' do
    t = profile.tasks.build; t.save!

    post :close, :tasks => {t.id => {:decision => 'cancel', :task => {}}}
    assert_redirected_to :action => 'index'

    t.reload
    ok('task should be cancelled') { t.status == Task::Status::CANCELLED }
  end

  should 'be able to skip a task' do
    t = profile.tasks.build; t.save!

    post :close, :tasks => {t.id => {:decision => 'skip', :task => {}}}
    assert_redirected_to :action => 'index'

    t.reload
    ok('task should be skipped') { t.status == Task::Status::ACTIVE }
  end

  should 'be able to apply different decisions to multiples tasks at the same time' do
    t1 = profile.tasks.build; t1.save!
    t2 = profile.tasks.build; t2.save!
    t3 = profile.tasks.build; t3.save!

    post :close, :tasks => {t1.id => {:decision => 'finish', :task => {}}, t2.id => {:decision => 'cancel', :task => {}}, t3.id => {:decision => 'skip', :task => {}}}
    assert_redirected_to :action => 'index'

    t1.reload
    t2.reload
    t3.reload

    ok('task should be finished') { t1.status == Task::Status::FINISHED }
    ok('task should be canceled') { t2.status == Task::Status::CANCELLED }
    ok('task should be skipped')  { t3.status == Task::Status::ACTIVE }
  end

  should 'affiliate roles to user after finish add member task' do
    t = AddMember.create!(:person => profile, :organization => profile)
    count = profile.members.size
    post :close, :tasks => {t.id => {:decision => 'finish', :task => {}}}
    profile = Profile.find(@profile.id)
    assert_equal count + 1, profile.members.size
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
    assert_difference 'Ticket.count' do
      post :new, :profile => profile.identifier, :ticket => {:name => 'test ticket'}
    end
  end

  should 'create a ticket with profile requestor' do
    post :new, :profile => profile.identifier, :ticket => {:name => 'new task'}
    
    assert_equal profile, assigns(:ticket).requestor
  end

  should 'list tasks that this profile created' do
    task = Ticket.create!(:name => 'test', :requestor => profile)
    get :list_requested, :profile => profile.identifier

    assert_includes assigns(:tasks), task
  end

  should 'list tasks that this profile created without spam' do
    task_spam = Ticket.create!(:name => 'test', :requestor => profile, :spam => true)
    task_ham = Ticket.create!(:name => 'test', :requestor => profile, :spam => false)
    get :list_requested, :profile => profile.identifier

    assert_includes assigns(:tasks), task_ham
    assert_not_includes assigns(:tasks), task_spam
  end

  should 'set target of ticket when creating it' do
     f = create_user('friend').person
     profile.add_friend f

     post :new, :profile => profile.identifier, :ticket => {:name => 'test ticket', :target_id => f.id, :target_type => 'Profile'}
     assert_response :redirect

     assert_equal f, assigns(:ticket).target
  end

  should 'create article with reference_article after finish approve article task' do
    c = fast_create(Community)
    c.update_attributes(:moderated_articles => false)
    @controller.stubs(:profile).returns(c)
    c.affiliate(profile, Profile::Roles.all_roles(profile.environment.id))
    article = profile.articles.create!(:name => 'something interesting', :body => 'ruby on rails')
    t = ApproveArticle.create!(:name => 'test name', :article => article, :target => c, :requestor => profile)

    post :close, :tasks => {t.id => {:decision => 'finish', :task => {:name => 'new_name'}}}
    assert_equal article, c.articles.find_by_name('new_name').reference_article
  end

  should 'create published article in folder after finish approve article task' do
    c = fast_create(Community)
    c.update_attributes(:moderated_articles => false)
    @controller.stubs(:profile).returns(c)
    folder = create(Folder, :profile => c, :name => 'test folder')
    c.affiliate(profile, Profile::Roles.all_roles(profile.environment.id))
    article = profile.articles.create!(:name => 'something interesting', :body => 'ruby on rails')
    t = ApproveArticle.create!(:name => 'test name', :article => article, :target => c, :requestor => profile)

    post :close, :tasks => {t.id => {:decision => 'finish', :task => {:name => 'new_name', :article_parent_id => folder.id}}}
    assert_equal folder, c.articles.find_by_name('new_name').parent
  end

  should 'be highlighted if asked when approving a published article' do
    c = fast_create(Community)
    c.update_attributes(:moderated_articles => false)
    @controller.stubs(:profile).returns(c)
    folder = create(Article, :profile => c, :name => 'test folder', :type => 'Folder')
    c.affiliate(profile, Profile::Roles.all_roles(profile.environment.id))
    article = profile.articles.create!(:name => 'something interesting', :body => 'ruby on rails')
    t = ApproveArticle.create!(:article => article, :target => c, :requestor => profile)

    post :close, :tasks => {t.id => {:decision => 'finish', :task => {:name => 'new_name', :article_parent_id => folder.id, :highlighted => true}}}
    assert_equal true, c.articles.find_by_name('new_name').highlighted
  end

  should 'create article of same class after choosing root folder on approve article task' do
    c = fast_create(Community)
    c.update_attributes(:moderated_articles => false)
    @controller.stubs(:profile).returns(c)
    c.affiliate(profile, Profile::Roles.all_roles(profile.environment.id))
    article = profile.articles.create!(:name => 'something interesting', :body => 'ruby on rails')
    t = ApproveArticle.create!(:article => article, :target => c, :requestor => profile)

    post :close, :tasks => {t.id => {:decision => 'finish', :task => {:name => 'new_name', :article_parent_id => ""}}}
    assert_not_nil c.articles.find_by_name('new_name')
  end

  should 'handle blank names for published articles' do
    c = fast_create(Community)
    @controller.stubs(:profile).returns(c)
    c.affiliate(profile, Profile::Roles.all_roles(c.environment))
    person = create_user('test_user').person
    p_blog = Blog.create!(:profile => person, :name => 'Blog')
    c_blog1 = Blog.create!(:profile => c, :name => 'Blog')
    c_blog2 = Blog.new(:profile => c); c_blog2.name = 'blog2'; c_blog2.save!

    article = person.articles.create!(:name => 'test article', :parent => p_blog)
    a = ApproveArticle.create!(:article => article, :target => c, :requestor => person)
    assert_includes c.tasks, a

    assert_difference 'article.class.count' do
      post :close, :tasks => {a.id => {:decision => 'finish', :task => {:name => "", :highlighted => "0", :article_parent_id => c_blog2.id.to_s}}}
    end
    assert p_article = article.class.find_by_reference_article_id(article.id)
    assert_includes c_blog2.children(true), p_article
  end

  should 'display error if there is an enterprise with the same identifier and keep the task active' do
    e = Environment.default
    e.add_admin(profile)
    task = CreateEnterprise.create!(:name => "My Enterprise", :identifier => "my-enterprise", :requestor => profile, :target => e)
    enterprise = fast_create(Enterprise, :name => "My Enterprise", :identifier => "my-enterprise")

    assert_nothing_raised do
      post :close, :tasks => {task.id => {:decision => "finish"}}
    end

    assert_match /Validation.failed/, @response.body

    task.reload
    assert_equal Task::Status::ACTIVE, task.status
  end

  should 'render TinyMce Editor when approving suggested article task' do
    Task.destroy_all
    c = fast_create(Community)
    c.add_admin profile
    @controller.stubs(:profile).returns(c)
    t = SuggestArticle.create!(:article_name => 'test name', :article_abstract => 'test abstract', :article_body => 'test body', :name => 'some name', :email => 'test@localhost.com', :target => c)

    get :index
    assert_tag :tag => 'textarea', :content => /test abstract/, :attributes => { :name => /article_abstract/, :class => 'mceEditor' }
    assert_tag :tag => 'textarea', :content => /test body/, :attributes => { :name => /article_body/, :class => 'mceEditor' }
  end

  should 'create TinyMceArticle article after finish approve suggested article task' do
    TinyMceArticle.destroy_all
    c = fast_create(Community)
    c.affiliate(profile, Profile::Roles.all_roles(profile.environment.id))
    @controller.stubs(:profile).returns(c)
    t = SuggestArticle.create!(:article_name => 'test name', :article_body => 'test body', :name => 'some name', :email => 'test@localhost.com', :target => c)

    post :close, :tasks => {t.id => { :task => {}, :decision => "finish"}}
    assert_not_nil TinyMceArticle.find(:first)
  end

  should "change the article's attributes on suggested article task approval" do
    TinyMceArticle.destroy_all
    c = fast_create(Community)
    c.affiliate(profile, Profile::Roles.all_roles(profile.environment.id))
    @controller.stubs(:profile).returns(c)
    t = SuggestArticle.new
    t.article_name = 'test name' 
    t.article_body = 'test body'
    t.name = 'some name'
    t.source = 'http://test.com'
    t.source_name = 'some source name'
    t.email = 'test@localhost.com'
    t.target = c
    t.save!

    post :close, :tasks => {t.id => { :task => {:article_name => 'new article name', :article_body => 'new body', :source => 'http://www.noosfero.com', :source_name => 'new source', :name => 'new name'}, :decision => "finish"}}
    assert_equal 'new article name', TinyMceArticle.find(:first).name
    assert_equal 'new name', TinyMceArticle.find(:first).author_name
    assert_equal 'new body', TinyMceArticle.find(:first).body
    assert_equal 'http://www.noosfero.com', TinyMceArticle.find(:first).source
    assert_equal 'new source', TinyMceArticle.find(:first).source_name
  end

  should "not crash if accessing close without tasks parameter" do
    assert_nothing_raised do
      post :close
    end
  end

  should 'close create enterprise if trying to cancel even if there is already an existing identifier' do
    identifier = "common-identifier"
    task = CreateEnterprise.create!(:identifier => identifier, :name => identifier, :requestor => profile, :target => profile)
    fast_create(Profile, :identifier => identifier)

    assert_nothing_raised do
      post :close, :tasks => {task.id => {:task => {:reject_explanation => "Some explanation"}, :decision => 'cancel'}}
    end

    task.reload
    assert_equal Task::Status::CANCELLED, task.status
  end

  should 'filter tasks by type' do
    class CleanHouse < Task; end
    class FeedDog < Task; end
    Task.stubs(:per_page).returns(3)
    requestor = fast_create(Person)
    t1 = CleanHouse.create!(:requestor => requestor, :target => profile)
    t2 = CleanHouse.create!(:requestor => requestor, :target => profile)
    t3 = FeedDog.create!(:requestor => requestor, :target => profile)

    post :index, :filter_type => t1.type

    assert_includes assigns(:tasks), t1
    assert_includes assigns(:tasks), t2
    assert_not_includes assigns(:tasks), t3

    post :index

    assert_includes assigns(:tasks), t1
    assert_includes assigns(:tasks), t2
    assert_includes assigns(:tasks), t3
  end

  should 'return tasks ordered accordingly and limited by pages' do
    time = Time.now
    person = fast_create(Person)
    t1 = create(Task, :status => Task::Status::ACTIVE, :target => profile, :requestor => person, :created_at => time)
    t2 = create(Task, :status => Task::Status::ACTIVE, :target => profile, :requestor => person, :created_at => time + 1.second)
    t3 = create(Task, :status => Task::Status::ACTIVE, :target => profile, :requestor => person, :created_at => time + 2.seconds)
    t4 = create(Task, :status => Task::Status::ACTIVE, :target => profile, :requestor => person, :created_at => time + 3.seconds)

    Task.stubs(:per_page).returns(2)

    post :index, :page => 1
    assert_equal [t1,t2], assigns(:tasks)

    Task.stubs(:per_page).returns(3)
    post :index, :page => 2
    assert_equal [t4], assigns(:tasks)
  end
end
