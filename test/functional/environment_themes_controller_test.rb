require_relative "../test_helper"

class EnvironmentThemesControllerTest < ActionController::TestCase

  def setup
    @controller = EnvironmentThemesController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new

    Theme.stubs(:user_themes_dir).returns(TMP_THEMES_DIR)

    @env = Environment.default
    login = create_admin_user(@env)
    login_as(login)
    @profile = User.find_by_login(login).person
  end

  def teardown
    FileUtils.rm_rf(TMP_THEMES_DIR)
  end

  TMP_THEMES_DIR = Rails.root.join("test", "tmp", "environment_themes_controller")

  should 'display themes that can be applied' do
    env = Environment.default
    Theme.stubs(:approved_themes).with(@env).returns([])
    t1 = 't1'
    t2 = 't2'
    t3 = 't3'
    env.themes = [t1, t2]
    env.save

    Theme.stubs(:system_themes).returns([Theme.new(t1), Theme.new(t2), Theme.new(t3)])
    get :index

    %w[ t1 t2 ].each do |item|
      assert_tag :tag => 'a', :attributes => { :href => "/admin/environment_themes/set/#{item}" }
    end

    assert_no_tag :tag => 'a', :attributes => { :href => "/admin/environment_themes/set/t3" }
  end

  should 'highlight current theme' do
    env = Environment.default
    t1 = 'one'
    t2 = 'two'
    env.themes = [t1, t2]
    env.save

    Theme.stubs(:system_themes).returns([Theme.new(t1), Theme.new(t2)])
    env.update_theme(t1)
    get :index

    assert_tag :attributes => { :class => 'theme-opt list-opt selected' }
    assert_no_tag :tag => 'a', :attributes => { :href => "/admin/environment_themes/set/one" }
  end

  should 'save selection of theme' do
    get :set, :id => 'onetheme'
    env = Environment.default
    assert_equal 'onetheme', env.theme
  end


  should 'unset selection of theme' do
    get :unset
    env = Environment.default
    assert_equal 'default', env.theme
  end

  should 'display link to use the default theme' do
    env = Environment.default
    env.themes = ['new-theme']
    env.save

    Theme.stubs(:system_themes).returns([Theme.new('new-theme')])

    get :index
    assert_tag :tag => 'a', :attributes => { :href => "/admin/environment_themes/unset" }
  end

  should 'point back to admin panel' do
    get :index
    assert_tag :tag => 'a', :attributes => { :href =>  '/admin' }, :content => 'Back'
  end

  should 'list templates' do
    all = LayoutTemplate.all

    LayoutTemplate.expects(:all).returns(all)
    get :index
    assert_equivalent all, assigns(:layout_templates)
  end

  should 'display links to set template' do
    env = Environment.default
    env.layout_template = 'rightbar'
    env.save!
    t1 = LayoutTemplate.find('default')
    t2 = LayoutTemplate.find('leftbar')
    LayoutTemplate.expects(:all).returns([t1, t2])

    get :index
    assert_tag :tag => 'a', :attributes => { :href => "/admin/environment_themes/set_layout_template/default"}
    assert_tag :tag => 'a', :attributes => { :href => "/admin/environment_themes/set_layout_template/leftbar"}
  end

  should 'highlight current template' do
    env = Environment.default
    env.update_attribute(:layout_template, 'default')
    env.layout_template = 'default'

    t1 = LayoutTemplate.find('default')
    t2 = LayoutTemplate.find('leftbar')
    LayoutTemplate.expects(:all).returns([t1, t2])

    get :index
    assert_tag :attributes => { :class => 'template-opt list-opt selected' }
    assert_no_tag :tag => 'a', :attributes => { :href => "/admin/environment_themes/set_layout_template/default"}
  end

  should 'set template' do
    env = Environment.default
    post :set_layout_template, :id => 'leftbar'
    env.reload
    assert_equal 'leftbar', env.layout_template
    assert_redirected_to :action => 'index'
  end

  should 'not display the "Select themes" section if there are no themes to choose from' do
    env = Environment.default
    env.themes = []; env.save!
    Theme.stubs(:system_themes_dir).returns(TMP_THEMES_DIR) # an empty dir
    get :index
    assert_no_tag :content => "Select theme"
  end

end
