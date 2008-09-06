require File.dirname(__FILE__) + '/../test_helper'
require 'test_controller'

# Re-raise errors caught by the controller.
class TestController; def rescue_action(e) raise e end; end

class ApplicationControllerTest < Test::Unit::TestCase
  all_fixtures
  def setup
    @controller = TestController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  def test_local_files_reference
    assert_local_files_reference
  end
  
  def test_valid_xhtml
    assert_valid_xhtml
  end

  def test_exist_environment_variable_to_helper_environment_identification
    get :index
    assert_not_nil assigns(:environment)
  end

  def test_get_against_post_only
    get :post_only
    assert_redirected_to :action => 'index'
  end
  def test_post_against_post_only
    post :post_only
    assert_response :success
    assert_tag :tag => 'span', :content => 'post_only'
  end

  def test_should_generate_help_box_when_passing_string
    get :help_with_string
    assert_tag({
      :tag => 'div',
      :attributes => { :class => 'help_box'},
      :descendant => {
        :tag => 'div',
        :attributes => { :class => 'help_message', :style => /display:\s+none/},
        :descendant => { :tag => 'div', :content => /my_help_message/ }
      }
    })
  end

  def test_should_generate_help_box_when_passing_block
    get :help_with_block
    assert_tag({
      :tag => 'div',
      :attributes => { :class => 'help_box'},
      :descendant => {
        :tag => 'div',
        :attributes => { :class => 'help_message', :style => /display:\s+none/},
        :descendant => { :tag => 'div', :content => /my_help_message/ }
      }
    })
  end

  def test_should_generate_help_box_expanding_textile_markup_when_passing_string
    get :help_textile_with_string
    assert_tag({
      :tag => 'div',
      :attributes => { :class => 'help_box'},
      :descendant => {
        :tag => 'div',
        :attributes => { :class => 'help_message', :style => /display:\s+none/},
        :descendant => {
          :tag => 'strong',
          :content => /my_bold_help_message/
        }
      }
    })
  end

  def test_should_generate_help_box_expanding_textile_markup_when_passing_block
    get :help_textile_with_block
    assert_tag({
      :tag => 'div',
      :attributes => { :class => 'help_box'},
      :descendant => {
        :tag => 'div',
        :attributes => { :class => 'help_message', :style => /display:\s+none/},
        :descendant => {
          :tag => 'strong',
          :content => /my_bold_help_message/
        }
      }
    })
  end

  def test_shouldnt_generate_help_box_markup_when_no_block_is_passed
    get :help_without_block
    assert_no_tag({
      :tag => 'div',
      :attributes => { :class => 'help_box'},
    })
  end

  should 'be able to not use design blocks' do

    class UsesBlocksTestController < ApplicationController
    end
    assert UsesBlocksTestController.new.uses_design_blocks?

    class DoesNotUsesBlocksTestController < ApplicationController
      no_design_blocks
    end
    assert !DoesNotUsesBlocksTestController.new.uses_design_blocks?
  end

  should 'use design plugin to generate blocks' do
    get :index
    assert_tag :tag => 'div', :attributes => { :id => 'boxes', :class => 'boxes' }
  end

  should 'not use design plugin when tells so' do
    class NoDesignBlocksTestController < ApplicationController
      no_design_blocks
    end
    @controller = NoDesignBlocksTestController.new
    get :index
    assert_no_tag :tag => 'div', :attributes => { :id => 'boxes', :class => 'boxes'  }
  end

  should 'display only some categories in menu' do
    c1 = Environment.default.categories.create!(:name => 'Category 1', :display_color => 1, :parent => nil, :display_in_menu => true )
    c2 = Environment.default.categories.create!(:name => 'Category 2', :display_color => nil, :parent => c1, :display_in_menu => true )
    get :index
    assert_tag :tag => 'a', :content => /Category 2/
  end

  should 'not display some categories in menu' do
    c1 = Environment.default.categories.create!(:name => 'Category 1', :display_color => 1, :parent_id => nil, :display_in_menu => true)
    c2 = Environment.default.categories.create!(:name => 'Category 2', :display_color => nil, :parent_id => c1)
    get :index
    assert_no_tag :tag => 'a', :content => /Category 2/
  end

  should 'display dropdown for select language' do
    Noosfero.expects(:locales).returns({ 'en' => 'English', 'pt_BR' => 'Português Brasileiro', 'fr' => 'Français', 'it' => 'Italiano' }).at_least_once
    get :index, :lang => 'en'
    assert_tag :tag => 'option', :attributes => { :value => 'en', :selected => 'selected' }, :content => 'English'
    assert_no_tag :tag => 'option', :attributes => { :value => 'pt_BR', :selected => 'selected' }, :content => 'Português Brasileiro'
    assert_tag :tag => 'option', :attributes => { :value => 'pt_BR' }, :content => 'Português Brasileiro'
    assert_tag :tag => 'option', :attributes => { :value => 'fr' }, :content => 'Français'
    assert_tag :tag => 'option', :attributes => { :value => 'it' }, :content => 'Italiano'
  end

  should 'display links for select language' do
    Noosfero.expects(:locales).returns({ 'en' => 'English', 'pt_BR' => 'Português Brasileiro', 'fr' => 'Français', 'it' => 'Italiano' }).at_least_once
    get :index, :lang => 'en'
    assert_no_tag :tag => 'a', :attributes => { :href => /\?lang=en/ }, :content => 'English'
    assert_tag :tag => 'a', :attributes => { :href => /\?lang=pt_BR/ }, :content => 'Português Brasileiro'
    assert_tag :tag => 'a', :attributes => { :href => /\?lang=fr/ }, :content => 'Français'
    assert_tag :tag => 'a', :attributes => { :href => /\?lang=it/ }, :content => 'Italiano'
  end

  should 'display link to webmail if enabled for system and for user' do
    login_as('ze')
    MailConf.expects(:enabled?).returns(true)
    MailConf.expects(:webmail_url).returns('http://web.mail/')
    User.any_instance.expects(:enable_email).returns(true)

    get :index
    assert_tag :tag => 'div', :attributes => { :id => 'user_box' }, :descendant => { :tag => 'a', :attributes => { :href => 'http://web.mail/' } }
  end

  should 'not display link to webmail if not enabled for system' do
    login_as('ze')
    MailConf.expects(:enabled?).returns(false)

    get :index
    assert_no_tag :tag => 'div', :attributes => { :id => 'user_box' }, :descendant => { :tag => 'a', :attributes => { :href => 'http://web.mail/' } }
  end

  should 'not display link in menu to webmail if not enabled for user' do
    login_as('ze')
    MailConf.expects(:enabled?).returns(true)
    User.any_instance.expects(:enable_email).returns(false)

    get :index
    assert_no_tag :tag => 'div', :attributes => { :id => 'user_box' }, :descendant => { :tag => 'a', :attributes => { :href => 'http://web.mail/' } }
  end

  should 'use environment top_url as base' do
    Environment.any_instance.expects(:top_url).returns('http://www.lala.net')
    get :index
    assert_tag :tag => 'base', :attributes => { :href => 'http://www.lala.net' }
  end

  should 'request environment top_url with ssl when under ssl for base' do
    Environment.any_instance.expects(:top_url).with(true).returns('https://www.lala.net/')
    @request.expects(:ssl?).returns(true).at_least_once
    get :index
    assert_tag :tag => 'base', :attributes => { :href => 'https://www.lala.net/' }
  end

  should 'display theme test panel when testing theme' do
    @request.session[:theme] = 'my-test-theme'
    theme = mock
    profile = mock
    theme.expects(:owner).returns(profile).at_least_once
    profile.expects(:identifier).returns('testinguser').at_least_once
    Theme.expects(:find).with('my-test-theme').returns(theme).at_least_once
    get :index

    assert_tag :tag => 'div', :attributes => { :id => 'theme-test-panel' }, :descendant => {
      :tag => 'a', :attributes => { :href => '/myprofile/testinguser/themes/edit/my-test-theme'}
    }
      #{ :tag => 'a', :attributes => { :href => '/myprofile/testinguser/themes/stop_test/my-test-theme'} }
  end

  should 'not display theme test panel in general' do
    @controller.stubs(:session).returns({})
    get :index
    assert_no_tag :tag => 'div', :attributes => { :id => 'theme-test-panel' }
  end

  should 'load terminology from environment' do
    term = Zen3Terminology.instance
    env = Environment.default
    Environment.stubs(:default).returns(env)
    env.stubs(:terminology).returns(term)

    Noosfero.expects(:terminology=).with(term)
    get :index
  end

  should 'require ssl when told to' do
    @request.expects(:ssl?).returns(false).at_least_once
    get :sslonly
    assert_redirected_to :protocol => 'https://'
  end

  should 'not force ssl in development mode' do
    ENV.expects(:[]).with('RAILS_ENV').returns('development')
    @request.expects(:ssl?).returns(false).at_least_once
    get :sslonly
    assert_response :success
  end

  should 'not force ssl when not told to' do
    @request.expects(:ssl?).returns(false).at_least_once
    get :doesnt_need_ssl
    assert_response :success
  end

  should 'not force ssl when already in ssl' do
    @request.expects(:ssl?).returns(true).at_least_once
    get :sslonly
    assert_response :success
  end

  should 'keep arguments when redirecting to ssl' do
    @request.expects(:ssl?).returns(false).at_least_once
    get :sslonly, :x => '1', :y => '2'
    assert_redirected_to :protocol => 'https://', :x => '1', :y => '2'
  end

  should 'refuse ssl when told to' do
    @request.expects(:ssl?).returns(true).at_least_once
    get :nossl
    assert_redirected_to :protocol => "http://"
  end

  should 'not refuse ssl when not told to' do
    @request.expects(:ssl?).returns(true).at_least_once
    get :doesnt_refuse_ssl
    assert_response :success
  end
  should 'not refuse ssl while in development mode' do
    ENV.expects(:[]).with('RAILS_ENV').returns('development')
    @request.expects(:ssl?).returns(true).at_least_once
    get :nossl
    assert_response :success
  end
  should 'not refuse ssl when not in ssl' do
    @request.expects(:ssl?).returns(false).at_least_once
    get :nossl
    assert_response :success
  end

  should 'keep arguments when redirecting to non-ssl' do
    @request.expects(:ssl?).returns(true).at_least_once
    get :nossl, :x => '1', :y => '2'
    assert_redirected_to :protocol => 'http://', :x => '1', :y => '2'
  end

  should 'add https protocols on redirect_to_ssl' do
    @controller.expects(:params).returns(:x => '1', :y => '1')
    @controller.expects(:redirect_to).with(:x => '1', :y => '1', :protocol => 'https://')
    @controller.redirect_to_ssl
  end

end
