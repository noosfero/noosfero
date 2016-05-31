require_relative "../test_helper"
require 'tasks_controller'

class TasksControllerTest < ActionController::TestCase

  self.default_params = {profile: 'testuser'}

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

 should 'get filtered tasks to autocomplete text field' do

   #Create a admin user and a simple user
   profile_admin = create_user('admin_tester').person
   Environment.default.add_admin(profile_admin)
   user = fast_create(Person,:name => 'FakeUser')

   #Create a task of type 'ModerateUserRegistration'
   task_data = {
       :target => Environment.default,
       :spam => false,
       :data => {:user_id => user.id,:name => user.name}
   }
   ModerateUserRegistration.create!(task_data)

   #Use admin user to your profile with a pending task above
   @controller.stubs(:profile).returns(profile_admin)
   login_as profile_admin.identifier

   #Perform a http request to 'search_task' action with params
   post :search_tasks, :filter_type =>'ModerateUserRegistration', :filter_text => 'Fak'

   assert_response :success

   #Check if json response matches with a 'FakeUser'
   json_response = ActiveSupport::JSON.decode(@response.body)
   value = json_response[0]['value']

   assert_equal value, 'FakeUser'
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
    assert !assigns(:tasks).nil?
    assert_kind_of ActiveRecord::Relation, assigns(:tasks)
  end

  should 'display task created_at' do
    Task.create!(:requestor => fast_create(Person), :target => profile, :spam => false)
    get :index
    assert_select '.task_date'
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

  should 'keep filters after close a task' do
    t = profile.tasks.build; t.save!

    post :close, :tasks => {t.id => {:decision => 'finish', :task => {}}}, :filter_type => t.type
    assert_redirected_to :action => 'index', :filter_type => t.type
    assert_equal @controller.params[:filter_type], t.type

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
    c = fast_create(Community)
    p = create_user('member').person

    @controller.stubs(:profile).returns(c)
    c.affiliate(profile, Profile::Roles.all_roles(profile.environment.id))

    t = AddMember.create!(:person => p, :organization => c)

    count = c.members.size

    post :close, :tasks => {t.id => {:decision => 'finish', :task => {}}}
    t.reload

    ok('task should be finished') { t.status == Task::Status::FINISHED }

    c.reload
    assert_equal count + 1, c.members.size
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
    c.update(:moderated_articles => false)
    @controller.stubs(:profile).returns(c)
    c.affiliate(profile, Profile::Roles.all_roles(profile.environment.id))
    article = profile.articles.create!(:name => 'something interesting', :body => 'ruby on rails')
    t = ApproveArticle.create!(:name => 'test name', :article => article, :target => c, :requestor => profile)

    post :close, :tasks => {t.id => {:decision => 'finish', :task => {:name => 'new_name'}}}
    assert_equal article, c.articles.find_by(name: 'new_name').reference_article
  end

  should 'create published article in folder after finish approve article task' do
    c = fast_create(Community)
    c.update(:moderated_articles => false)
    @controller.stubs(:profile).returns(c)
    folder = create(Folder, :profile => c, :name => 'test folder')
    c.affiliate(profile, Profile::Roles.all_roles(profile.environment.id))
    article = profile.articles.create!(:name => 'something interesting', :body => 'ruby on rails')
    t = ApproveArticle.create!(:name => 'test name', :article => article, :target => c, :requestor => profile)

    post :close, :tasks => {t.id => {:decision => 'finish', :task => {:name => 'new_name', :article_parent_id => folder.id}}}
    assert_equal folder, c.articles.find_by(name: 'new_name').parent
  end

  should 'be highlighted if asked when approving a published article' do
    c = fast_create(Community)
    c.update(:moderated_articles => false)
    @controller.stubs(:profile).returns(c)
    folder = create(Article, :profile => c, :name => 'test folder', :type => 'Folder')
    c.affiliate(profile, Profile::Roles.all_roles(profile.environment.id))
    article = profile.articles.create!(:name => 'something interesting', :body => 'ruby on rails')
    t = ApproveArticle.create!(:article => article, :target => c, :requestor => profile)

    post :close, :tasks => {t.id => {:decision => 'finish', :task => {:name => 'new_name', :article_parent_id => folder.id, :highlighted => true}}}
    assert_equal true, c.articles.find_by(name: 'new_name').highlighted
  end

  should 'create article of same class after choosing root folder on approve article task' do
    c = fast_create(Community)
    c.update(:moderated_articles => false)
    @controller.stubs(:profile).returns(c)
    c.affiliate(profile, Profile::Roles.all_roles(profile.environment.id))
    article = profile.articles.create!(:name => 'something interesting', :body => 'ruby on rails')
    t = ApproveArticle.create!(:article => article, :target => c, :requestor => profile)

    post :close, :tasks => {t.id => {:decision => 'finish', :task => {:name => 'new_name', :article_parent_id => ""}}}
    assert_not_nil c.articles.find_by(name: 'new_name')
  end

  should 'handle blank names for published articles' do
    c = fast_create(Community)
    @controller.stubs(:profile).returns(c)
    c.affiliate(profile, Profile::Roles.all_roles(c.environment))
    person = create_user('test_user').person
    c.add_member(person)
    p_blog = Blog.create!(:profile => person, :name => 'Blog')
    c_blog1 = Blog.create!(:profile => c, :name => 'Blog')
    c_blog2 = Blog.new(:profile => c); c_blog2.name = 'blog2'; c_blog2.save!

    article = person.articles.create!(:name => 'test article', :parent => p_blog)
    a = ApproveArticle.create!(:article => article, :target => c, :requestor => person)
    assert_includes c.tasks, a

    assert_difference 'article.class.count' do
      post :close, :tasks => {a.id => {:decision => 'finish', :task => {:name => "", :highlighted => "0", :article_parent_id => c_blog2.id.to_s}}}
    end
    assert p_article = article.class.find_by(reference_article_id: article.id)
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
    t = SuggestArticle.create!(:article => {:name => 'test name', :abstract => 'test abstract', :body => 'test body'}, :name => 'some name', :email => 'test@localhost.com', :target => c)

    get :index
    assert_tag :tag => 'textarea', :content => /test abstract/, :attributes => { :name => /tasks\[#{t.id}\]\[task\]\[article\]\[abstract\]/, :class => 'mceEditor' }
    assert_tag :tag => 'textarea', :content => /test body/, :attributes => { :name => /tasks\[#{t.id}\]\[task\]\[article\]\[body\]/, :class => 'mceEditor' }
  end

  should 'create TinyMceArticle article after finish approve suggested article task' do
    TinyMceArticle.destroy_all
    c = fast_create(Community)
    c.affiliate(profile, Profile::Roles.all_roles(profile.environment.id))
    @controller.stubs(:profile).returns(c)
    t = SuggestArticle.create!(:article => {:name => 'test name', :body => 'test body'}, :name => 'some name', :email => 'test@localhost.com', :target => c)

    post :close, :tasks => {t.id => { :task => {}, :decision => "finish"}}
    assert_not_nil TinyMceArticle.first
  end

  should "change the article's attributes on suggested article task approval" do
    TinyMceArticle.destroy_all
    c = fast_create(Community)
    c.affiliate(profile, Profile::Roles.all_roles(profile.environment.id))
    @controller.stubs(:profile).returns(c)
    t = SuggestArticle.new
    t.article = {:name => 'test name', :body => 'test body', :source => 'http://test.com', :source_name => 'some source name'}
    t.name = 'some name'
    t.email = 'test@localhost.com'
    t.target = c
    t.save!

    post :close, :tasks => {t.id => { :task => {:article => {:name => 'new article name', :body => 'new body', :source => 'http://www.noosfero.com', :source_name => 'new source'}, :name => 'new name'}, :decision => "finish"}}
    assert_equal 'new article name', TinyMceArticle.first.name
    assert_equal 'new name', TinyMceArticle.first.author_name
    assert_equal 'new body', TinyMceArticle.first.body
    assert_equal 'http://www.noosfero.com', TinyMceArticle.first.source
    assert_equal 'new source', TinyMceArticle.first.source_name
  end

  should "display name from article suggestion when requestor was not setted" do
    Task.destroy_all
    c = fast_create(Community)
    c.add_admin profile
    @controller.stubs(:profile).returns(c)
    t = SuggestArticle.create!(:article => {:name => 'test name', :abstract => 'test abstract', :body => 'test body'}, :name => 'some name', :email => 'test@localhost.com', :target => c)

    get :index
    assert_select "#tasks_#{t.id}_task_name"
  end

  should "not crash when article suggestion task fails" do
    TinyMceArticle.destroy_all
    c = fast_create(Community)
    c.affiliate(profile, Profile::Roles.all_roles(profile.environment.id))
    @controller.stubs(:profile).returns(c)
    t = SuggestArticle.create!(:article => {:name => 'test name', :abstract => 'test abstract', :body => 'test body'}, :name => 'some name', :email => 'test@localhost.com', :target => c)

    SuggestArticle.any_instance.stubs(:perform).raises('erro')
    assert_nothing_raised do
      post :close, :tasks => {t.id => { :task => {}, :decision => "finish"}}
    end
  end

  should "append hidden tag with type value from article suggestion" do
    Task.destroy_all
    c = fast_create(Community)
    c.add_admin profile
    @controller.stubs(:profile).returns(c)
    t = SuggestArticle.create!(:article => {:name => 'test name', :abstract => 'test abstract', :body => 'test body', :type => 'TextArticle'}, :name => 'some name', :email => 'test@localhost.com', :target => c)

    get :index
    assert_select "#tasks_#{t.id}_task_article_type[value=TextArticle]"
  end

  should "display parent_id selection from article suggestion with predefined value" do
    Task.destroy_all
    c = fast_create(Community)
    c.add_admin profile
    @controller.stubs(:profile).returns(c)
    parent = fast_create(Folder, :profile_id => c.id)
    t = SuggestArticle.create!(:article => {:name => 'test name', :abstract => 'test abstract', :body => 'test body', :parent_id => parent.id}, :name => 'some name', :email => 'test@localhost.com', :target => c)

    get :index
    assert_select "#tasks_#{t.id}_task_article_parent_id option[value=#{parent.id}]"
  end

  should "not display name from article suggestion when requestor was setted" do
    Task.destroy_all
    c = fast_create(Community)
    c.add_admin profile
    @controller.stubs(:profile).returns(c)
    t = SuggestArticle.create!(:article => {:name => 'test name', :abstract => 'test abstract', :body => 'test body'}, :requestor => fast_create(Person), :target => c)

    get :index
    assert_select "#tasks_#{t.id}_task_name", 0
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

  should 'filter tasks by type and data content' do
    class CleanHouse < Task; end
    class FeedDog < Task; end
    Task.stubs(:per_page).returns(3)
    requestor = fast_create(Person)
    t1 = CleanHouse.create!(:requestor => requestor, :target => profile, :data => {:name => 'Task Test'})
    t2 = CleanHouse.create!(:requestor => requestor, :target => profile)
    t3 = FeedDog.create!(:requestor => requestor, :target => profile)

    post :index, :filter_type => t1.type, :filter_text => 'test'

    assert_includes assigns(:tasks), t1
    assert_not_includes assigns(:tasks), t2
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

  should 'filter tasks by responsible' do
    Task.stubs(:per_page).returns(3)
    requestor = fast_create(Person)
    responsible = fast_create(Person)
    t1 = Task.create!(:requestor => requestor, :target => profile, :responsible => responsible)
    t2 = Task.create!(:requestor => requestor, :target => profile, :responsible => responsible)
    t3 = Task.create!(:requestor => requestor, :target => profile)

    get :index, :filter_responsible => responsible.id

    assert_includes assigns(:tasks), t1
    assert_includes assigns(:tasks), t2
    assert_not_includes assigns(:tasks), t3

    get :index

    assert_includes assigns(:tasks), t1
    assert_includes assigns(:tasks), t2
    assert_includes assigns(:tasks), t3
  end

  should 'do not display responsible assignment if profile is not an organization' do
    profile = create_user('personprofile').person
    t1 = Task.create!(:requestor => profile, :target => profile)
    @controller.stubs(:profile).returns(profile)
    login_as profile.user.login
    get :index

    assert_select "#task-#{t1.id}"
    assert_select '.task_responsible', 0
  end

  should 'do not display responsible assignment filter if profile is not an organization' do
    profile = create_user('personprofile').person
    @controller.stubs(:profile).returns(profile)
    login_as profile.user.login
    get :index

    assert_select '.filter_responsible', 0
  end

  should 'display responsible assignment if profile is an organization' do
    profile = fast_create(Community)
    person1 = create_user('person1').person
    person2 = create_user('person2').person
    person3 = create_user('person3').person
    profile.add_admin(person1)
    profile.add_admin(person2)
    profile.add_member(person3)
    Task.create!(:requestor => person3, :target => profile)
    @controller.stubs(:profile).returns(profile)

    login_as person1.user.login
    get :index
    assert_equivalent [person1, person2], assigns(:responsible_candidates)
    assert_select '.task_responsible'
  end

  should 'change task responsible' do
    profile = fast_create(Community)
    @controller.stubs(:profile).returns(profile)
    person = create_user('person1').person
    profile.add_admin(person)
    task = Task.create!(:requestor => person, :target => profile)

    assert_equal nil, task.responsible
    login_as person.user.login
    post :change_responsible, :task_id => task.id, :responsible_id => person.id
    assert_equal person, task.reload.responsible
  end

  should 'not change task responsible if old responsible is not the current' do
    profile = fast_create(Community)
    @controller.stubs(:profile).returns(profile)
    person1 = create_user('person1').person
    person2 = create_user('person2').person
    profile.add_admin(person1)
    task = Task.create!(:requestor => person1, :target => profile, :responsible => person1)

    login_as person1.user.login
    post :change_responsible, :task_id => task.id, :responsible_id => person2.id, :old_responsible => nil
    assert_equal person1, task.reload.responsible
    json_response = ActiveSupport::JSON.decode(response.body)
    refute json_response['success']
  end

  should 'list tasks for user with only view_tasks permission' do
    community = fast_create(Community)
    @controller.stubs(:profile).returns(community)
    person = create_user_with_permission('taskviewer', 'view_tasks', community)
    login_as person.user.login
    get :index
    assert_response :success
    assert assigns(:view_only)
  end

  should 'forbid user with only view_tasks permission to close a task' do
    community = fast_create(Community)
    @controller.stubs(:profile).returns(community)
    person = create_user_with_permission('taskviewer', 'view_tasks', community)
    login_as person.user.login
    post :close
    assert_response 403
  end

  should 'hide tasks actions when user has only view_tasks permission' do
    community = fast_create(Community)
    @controller.stubs(:profile).returns(community)
    person = create_user_with_permission('taskviewer', 'view_tasks', community)
    login_as person.user.login

    Task.create!(:requestor => person, :target => community)
    get :index

    assert_select '.task-actions', 0
  end

  should 'display tasks actions when user has perform_task permission' do
    community = fast_create(Community)
    @controller.stubs(:profile).returns(community)
    person = create_user_with_permission('taskperformer', 'perform_task', community)
    login_as person.user.login

    Task.create!(:requestor => person, :target => community)
    get :index

    assert_select '.task-actions', 2
  end

  should 'hide decision selector when user has only view_tasks permission' do
    community = fast_create(Community)
    @controller.stubs(:profile).returns(community)
    person = create_user_with_permission('taskviewer', 'view_tasks', community)
    login_as person.user.login

    Task.create!(:requestor => person, :target => community)
    get :index

    assert_select '#up-set-all-tasks-to', 0
    assert_select '#down-set-all-tasks-to', 0
  end

  should 'display decision selector when user has perform_task permission' do
    community = fast_create(Community)
    @controller.stubs(:profile).returns(community)
    person = create_user_with_permission('taskperformer', 'perform_task', community)
    login_as person.user.login

    Task.create!(:requestor => person, :target => community)
    get :index

    assert_select '#up-set-all-tasks-to'
    assert_select '#down-set-all-tasks-to'
  end

  should 'hide decision buttons when user has only view_tasks permission' do
    community = fast_create(Community)
    @controller.stubs(:profile).returns(community)
    person = create_user_with_permission('taskviewer', 'view_tasks', community)
    login_as person.user.login

    task = Task.create!(:requestor => person, :target => community)
    get :index

    assert_select "#decision-finish-#{task.id}", 0
    assert_select "#decision-cancel-#{task.id}", 0
    assert_select "#decision-skip-#{task.id}", 0
  end

  should 'display decision buttons when user has perform_task permission' do
    community = fast_create(Community)
    @controller.stubs(:profile).returns(community)
    person = create_user_with_permission('taskperformer', 'perform_task', community)
    login_as person.user.login

    task = Task.create!(:requestor => person, :target => community)
    get :index

    assert_select "#decision-finish-#{task.id}"
    assert_select "#decision-cancel-#{task.id}"
    assert_select "#decision-skip-#{task.id}"
  end

  should 'hide responsive selection when user has only view_tasks permission' do
    community = fast_create(Community)
    @controller.stubs(:profile).returns(community)
    person = create_user_with_permission('taskviewer', 'view_tasks', community)
    login_as person.user.login

    task = Task.create!(:requestor => person, :target => community, :responsible => person)
    get :index

    assert_select ".task_responsible select", 0
    assert_select ".task_responsible .value"
  end

  should 'store the person who closes a task' do
    t = profile.tasks.build; t.save!
    post :close, :tasks => {t.id => {:decision => 'finish', :task => {}}}
    assert_equal profile, t.reload.closed_by
  end

  should 'list custom field details in moderation user tasks when moderation_tasks is true' do
    person_custom_field = CustomField.create(:name => "great_field", :format=>"string", :default_value => "value for person", :customized_type=>"Person", :active => true, :environment => Environment.default, :moderation_task => true, :required => true)
    p1 = create_user("great_person").person
    p1.custom_values = {"great_field" => "new_value!"}
    p1.save!
    p1.reload
    admin = create_user("admin").person
    Environment.default.add_admin(admin)
    @controller.stubs(:profile).returns(admin)
    login_as "admin"

    ModerateUserRegistration.create!(:requestor => p1, :name => "great_person", :email => "alo@alo.alo", :target => Environment.default)

    get :index

    assert_tag :tag=> 'div', :attributes => { :class => 'field-name' }, :content => /great_field: new_value!/
  end

  should 'list custom field details in moderation of community creation tasks when moderation_tasks is true' do
    community_custom_field = CustomField.create(:name => "great_field", :format=>"string", :default_value => "value for community", :customized_type=>"Community", :active => true, :environment => Environment.default, :moderation_task => true, :required => true)
    p1 = create_user("great_person").person
    p1.save!
    admin = create_user("admin").person
    Environment.default.add_admin(admin)
    @controller.stubs(:profile).returns(admin)
    login_as "admin"

    CreateCommunity.create!(:requestor => p1, :name => "great_community", :target => Environment.default, :custom_values => {"great_field" => {"value" => "new value for community!"}})

    get :index

    assert_tag :tag=> 'div', :attributes => { :class => 'field-name' }, :content => /great_field: new value for community!/
  end

  should "display email template selection when accept a task" do
    community = fast_create(Community)
    @controller.stubs(:profile).returns(community)
    person = create_user_with_permission('taskviewer', 'view_tasks', community)
    login_as person.user.login

    email_template = EmailTemplate.create!(:name => 'template', :owner => community, :template_type => :task_acceptance)
    task = ApproveArticle.create!(:requestor => person, :target => community, :responsible => person)
    get :index
    assert_select "#on-accept-information-#{task.id} .template-selection"
    assert_equal [email_template], assigns(:acceptance_email_templates)
  end

  should "display email template selection when reject a task" do
    community = fast_create(Community)
    @controller.stubs(:profile).returns(community)
    person = create_user_with_permission('taskviewer', 'view_tasks', community)
    login_as person.user.login

    email_template = EmailTemplate.create!(:name => 'template', :owner => community, :template_type => :task_rejection)
    task = ApproveArticle.create!(:requestor => person, :target => community, :responsible => person)
    get :index
    assert_select "#on-reject-information-#{task.id} .template-selection"
    assert_equal [email_template], assigns(:rejection_email_templates)
  end

  should 'filter processed tasks by all filters' do
    requestor = fast_create(Person)
    closed_by = fast_create(Person)
    class AnotherTask < Task; end

    created_date = DateTime.now
    processed_date = DateTime.now

    task_params = {:status => Task::Status::FINISHED, :requestor => requestor, :target => profile, :created_at => created_date, :end_date => processed_date, :closed_by => closed_by, :data => {:field => 'some data field'}}

    task = create(AnotherTask, task_params)
    create(Task, task_params)
    create(AnotherTask, task_params.clone.merge(:status => Task::Status::CANCELLED))
    create(AnotherTask, task_params.clone.merge(:created_at => created_date - 1.day))
    create(AnotherTask, task_params.clone.merge(:created_at => created_date + 1.day))
    create(AnotherTask, task_params.clone.merge(:end_date => processed_date - 1.day))
    create(AnotherTask, task_params.clone.merge(:end_date => processed_date + 1.day))
    create(AnotherTask, task_params.clone.merge(:requestor => fast_create(Person, :name => 'another-requestor')))
    create(AnotherTask, task_params.clone.merge(:closed_by => fast_create(Person, :name => 'another-closer')))
    create(AnotherTask, task_params.clone.merge(:data => {:field => "other data field"}))

    get :processed, :filter => {:type => AnotherTask, :status => Task::Status::FINISHED, :created_from => created_date, :created_until => created_date, :closed_from => processed_date, :closed_until => processed_date, :requestor => requestor.name, :closed_by => closed_by.name, :text => "some data field"}
    assert_response :success
    assert_equal [task], assigns(:tasks)
  end

end
