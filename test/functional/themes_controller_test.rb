require File.dirname(__FILE__) + '/../test_helper'
require 'themes_controller'

class ThemesController; def rescue_action(e) raise e end; end

class ThemesControllerTest < Test::Unit::TestCase

  def setup
    @controller = ThemesController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new

    Theme.stubs(:user_themes_dir).returns(TMP_THEMES_DIR)

    @profile = create_user('testinguser').person
    login_as('testinguser')
  end
  attr_reader :profile

  def teardown
    FileUtils.rm_rf(TMP_THEMES_DIR)
  end

  TMP_THEMES_DIR = RAILS_ROOT + '/test/tmp/themes_controller'

  should 'display list of themes for selection' do
    Theme.expects(:system_themes).returns([Theme.new('first'), Theme.new('second')])
    get :index, :profile => 'testinguser'

    %w[ first second ].each do |item|
      assert_tag :tag => 'a', :attributes => { :href => "/myprofile/testinguser/themes/set/#{item}" }
    end
  end

  should 'display list of my themes for edition' do
    Theme.create('first', :owner => profile)
    Theme.create('second', :owner => profile)

    get :index, :profile => 'testinguser'

    %w[ first second ].each do |item|
      assert_tag :tag => 'a', :attributes => { :href => "/myprofile/testinguser/themes/edit/#{item}" }
    end
  end

  should 'save selection of theme' do
    get :set, :profile => 'testinguser', :id => 'onetheme'
    profile.reload
    assert_equal 'onetheme', profile.theme
  end

  should 'point back to control panel' do
    get :index, :profile => 'testinguser'
    assert_tag :tag => 'a', :attributes => { :href =>  '/myprofile/testinguser' }, :content => 'Back'
  end

  should 'display screen for creating new theme' do
    @request.expects(:xhr?).returns(true).at_least_once
    get :new, :profile => 'testinguser'
    assert_tag :tag => 'form', :attributes => { :action => '/myprofile/testinguser/themes/new', :method => /post/i }, :descendant => { :tag => 'input', :attributes => { :type => 'text', :name => 'name' } }
  end

  should 'create a new theme' do
    post :new, :profile => 'testinguser', :name => 'My theme'
    
    ok('theme should be created') do
      profile.themes.first.id == 'my-theme'
    end
  end

  should 'edit a theme' do
    theme = Theme.create('mytheme', :owner => profile)
    get :edit, :profile => 'testinguser', :id => 'mytheme'

    assert_equal theme, assigns(:theme)
  end

  should 'list CSS files in theme' do
    theme = Theme.create('mytheme', :owner => profile)
    theme.add_css('one.css')
    theme.add_css('two.css')

    get :edit, :profile => 'testinguser', :id => 'mytheme'

    %w[ one.css two.css ].each do |item|
      assert_includes assigns(:css_files), item
      assert_tag :tag => 'li', :descendant => { :tag => 'a', :content => item}
    end
  end

  should 'display dialog for creating new CSS' do
    theme = Theme.create('mytheme', :owner => profile)
    @request.expects(:xhr?).returns(true)
    get :add_css, :profile => 'testinguser', :id => 'mytheme'

    assert_tag :tag => 'form', :attributes => { :action => '/myprofile/testinguser/themes/add_css/mytheme', :method => /post/i}
    assert_tag :tag => 'input', :attributes => { :name => 'css', :type => 'text' }
    assert_tag :tag => 'input', :attributes => { :type => 'submit' }
  end

  should 'be able to add new CSS to theme' do
    theme = Theme.create('mytheme', :owner => profile)
    post :add_css, :profile => 'testinguser', :id => 'mytheme', :css => 'test.css'

    assert_response :redirect

    reloaded_theme = Theme.find('mytheme')
    assert_includes reloaded_theme.css_files, 'test.css'
  end

  should 'load code from a given CSS file' do
    theme = Theme.create('mytheme', :owner => profile); theme.update_css('test.css', '/* sample code */')
    get :css_editor, :profile => 'testinguser', :id => 'mytheme', :css => 'test.css'

    assert_tag :tag => 'form', :attributes => { :action => '/myprofile/testinguser/themes/update_css/mytheme' }, :descendant => { :tag => 'textarea', :content => '/* sample code */' }
  end

  should 'be able to save CSS code' do
    theme = Theme.create('mytheme', :owner => profile); theme.update_css('test.css', '/* sample code */')
    get :css_editor, :profile => 'testinguser', :id => 'mytheme', :css => 'test.css'

    assert_tag :tag => 'form', :attributes => { :action => '/myprofile/testinguser/themes/update_css/mytheme' }, :descendant => { :tag => 'input', :attributes => { :type => 'submit' } }
    assert_tag :tag => 'form', :attributes => { :action => '/myprofile/testinguser/themes/update_css/mytheme' }, :descendant => { :tag => 'input', :attributes => { :type => 'hidden', :name => 'css', :value => 'test.css' } }
  end

  should 'update css code when saving' do
    theme = Theme.create('mytheme', :owner => profile); theme.update_css('test.css', '/* sample code */')
    post :update_css, :profile => 'testinguser', :id => 'mytheme', :css => 'test.css', :csscode => 'body { background: white; }'
    assert_equal 'body { background: white; }', theme.read_css('test.css')
  end

  should 'list image files in theme' do
    theme = Theme.create('mytheme', :owner => profile)
    theme.add_image('one.png', 'FAKE IMAGE DATA 1')
    theme.add_image('two.png', 'FAKE IMAGE DATA 2')

    get :edit, :profile => 'testinguser', :id => 'mytheme'

    assert_tag :tag => 'img', :attributes => { :src => '/user_themes/mytheme/images/one.png' }
    assert_tag :tag => 'img', :attributes => { :src => '/user_themes/mytheme/images/two.png' }
  end

  should 'display "add image" button' do
    theme = Theme.create('mytheme', :owner => profile)
    get :edit, :profile => 'testinguser', :id => 'mytheme'
    
    assert_tag :tag => 'a', :attributes => { :href => '/myprofile/testinguser/themes/add_image/mytheme' }
  end

  should 'display the "add image" dialog' do
    theme = Theme.create('mytheme', :owner => profile)
    @request.expects(:xhr?).returns(true)

    get :add_image, :profile => 'testinguser', :id => 'mytheme'
    assert_tag :tag => 'form', :attributes => { :action => '/myprofile/testinguser/themes/add_image/mytheme', :method => /post/i, :enctype => 'multipart/form-data' }, :descendant => { :tag => 'input', :attributes => { :name => 'image', :type => 'file' } }
  end

  should 'be able to add new image to theme' do
    theme = Theme.create('mytheme', :owner => profile)
    @request.expects(:xhr?).returns(false)

    post :add_image, :profile => 'testinguser', :id => 'mytheme', :image => fixture_file_upload('/files/rails.png', 'image/png', :binary)
    assert_redirected_to :action => "edit", :id => 'mytheme'
    assert theme.image_files.include?('rails.png')
    assert(system('diff', RAILS_ROOT + '/test/fixtures/files/rails.png', TMP_THEMES_DIR + '/mytheme/images/rails.png'), 'should put the correct uploaded file in the right place')
  end

  should 'link to "test theme"' do
    Theme.create('one', :owner => profile)
    Theme.create('two', :owner => profile)
    get :index, :profile => 'testinguser'

    %w[ one two ].each do |item|
      assert_tag :tag => 'a', :attributes => { :href => '/myprofile/testinguser/themes/start_test/' + item }
    end
  end

  should 'start testing theme' do
    theme = Theme.create('theme-under-test', :owner => profile)
    post :start_test, :profile => 'testinguser', :id => 'theme-under-test'

    assert_equal 'theme-under-test', session[:theme]
    assert_redirected_to :controller => 'content_viewer', :profile => 'testinguser'
  end

  should 'stop testing theme' do
    theme = Theme.create('theme-under-test', :owner => profile)
    post :stop_test, :profile => 'testinguser', :id => 'theme-under-test'

    assert_nil session[:theme]
    assert_redirected_to :action => 'index'
  end

end
