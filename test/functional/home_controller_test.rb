require File.dirname(__FILE__) + '/../test_helper'
require 'home_controller'

# Re-raise errors caught by the controller.
class HomeController; def rescue_action(e) raise e end; end

class HomeControllerTest < ActionController::TestCase

  def teardown
    Thread.current[:enabled_plugins] = nil
  end

  all_fixtures
  def setup
    @controller = HomeController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  def test_local_files_reference
    assert_local_files_reference
  end
  
  def test_valid_xhtml
    assert_valid_xhtml
  end

  should 'not display news from portal if disabled in environment' do
    env = Environment.default
    env.disable('use_portal_community')
    env.save!

    get :index
    assert_no_tag :tag => 'div', :attributes => { :id => 'portal-news' }
  end

  should 'not display news from portal if environment doesnt have portal community' do
    env = Environment.default
    env.enable('use_portal_community')
    env.save!

    get :index
    assert_no_tag :tag => 'div', :attributes => { :id => 'portal-news' }
  end

  should 'display news from portal if enabled and has portal community' do
    env = Environment.default
    env.enable('use_portal_community')

    c = Community.create!(:name => 'community test')
    env.portal_community = c

    env.save!

    get :index
    assert_tag :tag => 'div', :attributes => { :id => 'portal-news' } #, :descendant => {:tag => 'form', :attributes => {:action => '/account/activation_question'}}
  end

  should 'display the news leads if there is any' do
    env = Environment.default
    env.enable('use_portal_community')
    c = fast_create(Community)
    a1 = TextileArticle.create!(:name => "Article 1",
                                :profile => c,
                                :abstract => "This is the article1 lead.",
                                :body => "This is the article1 body.",
                                :highlighted => true)
    a2 = TextileArticle.create!(:name => "Article 2",
                                :profile => c,
                                :body => "This is the article2 body.",
                                :highlighted => true)
    env.portal_community = c
    env.save!


    get :index
    assert_tag :attributes => { :class => 'headline' }, :content => a1.abstract
    assert_no_tag :attributes => { :class => 'headline' }, :content => a1.body
    assert_tag :attributes => { :class => 'headline' }, :content => a2.body
  end

  should 'display block in index page if it\'s configured to display on homepage and its an environment block' do
    env = Environment.default
    box = Box.create(:owner_type => 'Environment', :owner_id => env.id)
    block = Block.create(:title => "Index Block", :box_id => box.id, :display => 'home_page_only')
    env.save!

    get :index
    assert block.visible?
  end

  should 'access terms of use of environment' do
    env = Environment.default
    env.update_attribute(:terms_of_use, 'Noosfero terms of use')
    get :terms
    assert_tag :content => /Noosfero terms of use/
  end

  should 'provide a link to make the user authentication' do
    class Plugin1 < Noosfero::Plugin
      def alternative_authentication_link
        lambda {"<a href='plugin1'>Plugin1 link</a>"}
      end
    end
    class Plugin2 < Noosfero::Plugin
      def alternative_authentication_link
        lambda {"<a href='plugin2'>Plugin2 link</a>"}
      end
    end

    Environment.default.enable_plugin(Plugin1)
    Environment.default.enable_plugin(Plugin2)

    get :index

    assert_tag :tag => 'a', :content => 'Plugin1 link'
    assert_tag :tag => 'a', :content => 'Plugin2 link'
  end

  should "not display the new user button on login page if now allowed by any plugin" do
    class Plugin1 < Noosfero::Plugin
      def allow_user_registration
        false
      end
    end

    class Plugin2 < Noosfero::Plugin
      def allow_user_registration
        true
      end
    end
    Noosfero::Plugin::Manager.any_instance.stubs(:enabled_plugins).returns([Plugin1.new, Plugin2.new])

    get :index

    assert_no_tag :tag => 'a', :attributes => {:href => '/account/signup'}
  end

end
