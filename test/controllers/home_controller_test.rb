require_relative '../test_helper'

class HomeControllerTest < ActionController::TestCase

  def teardown
    Thread.current[:enabled_plugins] = nil
  end

  all_fixtures
  def setup
    @controller = HomeController.new
    @admin = create_user.person
    Environment.default.add_admin @admin
  end

  should 'not display news from portal if disabled in environment' do
    env = Environment.default
    env.disable('use_portal_community')
    env.save!

    get :index
    !assert_tag :tag => 'div', :attributes => { :id => 'portal-news' }
  end

  should 'not display news from portal if environment doesnt have portal community' do
    env = Environment.default
    env.enable('use_portal_community')
    env.save!

    get :index
    !assert_tag :tag => 'div', :attributes => { :id => 'portal-news' }
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
    a1 = TextArticle.create!(:name => "Article 1",
                                :profile => c,
                                :abstract => "This is the article1 lead.",
                                :body => "<p>This is the article1 body.</p>",
                                :highlighted => true)
    a2 = TextArticle.create!(:name => "Article 2",
                                :profile => c,
                                :body => "<p>This is the article2 body.</p>",
                                :highlighted => true)
    env.portal_community = c
    env.save!


    get :index
    assert_tag :attributes => { :class => 'headline' }, :content => a1.abstract
    !assert_tag :attributes => { :class => 'headline' }, :content => 'This is the article1 body.'
    assert_tag :attributes => { :class => 'headline' }, :content => 'This is the article2 body.'
  end

  should 'display block in index page if it\'s configured to display on homepage and its an environment block' do
    env = Environment.default
    box = create(Box, :owner_type => 'Environment', :owner_id => env.id)
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
        proc {"<a href='plugin1'>Plugin1 link</a>".html_safe}
      end
    end
    class Plugin2 < Noosfero::Plugin
      def alternative_authentication_link
        proc {"<a href='plugin2'>Plugin2 link</a>".html_safe}
      end
    end
    Noosfero::Plugin.stubs(:all).returns([Plugin1.name, Plugin2.name])

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
    Noosfero::Plugin.stubs(:all).returns([Plugin1.name, Plugin2.name])
    Noosfero::Plugin::Manager.any_instance.stubs(:enabled_plugins).returns([Plugin1.new, Plugin2.new])

    get :index

    !assert_tag :tag => 'a', :attributes => {:href => '/account/signup'}
  end

  should 'display template welcome page' do
    template = create_user('template').person
    template.is_template = true
    welcome_page = TextArticle.create!(:name => 'Welcome page', :profile => template, :published => true, :body => 'Template welcome page')
    template.welcome_page = welcome_page
    template.save!
    get :welcome, :template_id => template.id
    assert_match /#{welcome_page.body}/, @response.body
  end

  should 'not display template welcome page if it is not published' do
    template = create_user('template').person
    template.is_template = true
    welcome_page = TextArticle.create!(:name => 'Welcome page', :profile => template, :body => 'Template welcome page', access: Entitlement::Levels.levels[:self])
    template.welcome_page = welcome_page
    template.save!
    get :welcome, :template_id => template.id
    assert_no_match /#{welcome_page.body}/, @response.body
  end

  should 'not crash template doess not have a welcome page' do
    template = create_user('template').person
    template.is_template = true
    template.save!
    assert_nothing_raised do
      get :welcome, :template_id => template.id
    end
  end

  should 'add class to the <html>' do
    get :index

    # Where am i?
    assert_select 'html.controller-home.action-home-index'
    # What is the current layout?
    assert_select 'html.template-default.theme-noosfero'
  end

  should 'plugins add class to the <html>' do
    class Plugin1 < Noosfero::Plugin
      def html_tag_classes
        lambda { ['t1'.html_safe, 't2'.html_safe] }
      end
    end

    class Plugin2 < Noosfero::Plugin
      def html_tag_classes
        'test'
      end
    end

    Noosfero::Plugin.stubs(:all).returns([Plugin1.name, Plugin2.name])
    Noosfero::Plugin::Manager.any_instance.stubs(:enabled_plugins).returns([Plugin1.new, Plugin2.new])

    get :index

    # Where am i?
    assert_select 'html.controller-home.action-home-index'
    # There are plugin classes?
    assert_select 'html.t1.t2.test'
  end

  should 'display move options to admins' do
    login_as @admin.identifier
    community = fast_create(Community)
    fast_create(TextArticle, profile_id: community.id, highlighted: true)

    env = Environment.default
    env.portal_community = community
    env.enable('use_portal_community')
    env.save!

    get :index
    assert_select '.order-options', { count: 1 }
  end

  should 'not display move options to regular users' do
    user = create_user.person
    login_as user.identifier
    community = fast_create(Community)
    fast_create(TextArticle, profile_id: community.id, highlighted: true)

    env = Environment.default
    env.portal_community = community
    env.enable('use_portal_community')
    env.save!

    get :index
    assert_select '.order-options', { count: 0 }
  end

  should 'not display move options to visitors' do
    logout
    community = fast_create(Community)
    fast_create(TextArticle, profile_id: community.id, highlighted: true)

    env = Environment.default
    env.portal_community = community
    env.enable('use_portal_community')
    env.save!

    get :index
    assert_select '.order-options', { count: 0 }
  end

  should 'render 400 if index is not sent' do
    login_as @admin.identifier
    get :reorder, index: nil, direction: 'up'
    assert_response 400
  end

  should 'render 400 if direction is not sent' do
    login_as @admin.identifier
    get :reorder, index: 0, direction: nil
    assert_response 400
  end

  should 'render 400 if direction is invalid' do
    login_as @admin.identifier
    get :reorder, index: 0, direction: 'invalid'
    assert_response 400
  end

  should 'render 403 if user is not an admin' do
    user = create_user.person
    login_as user.identifier

    get :reorder, index: 0, direction: 'up'
    assert_response 403
  end

  should 'render 403 if there is no current user' do
    logout
    get :reorder, index: 0, direction: 'up'
    assert_response 403
  end

  should 'move an article up' do
    login_as @admin.identifier
    community = fast_create(Community)
    article1 = create(TextArticle, profile_id: community.id, highlighted: true,
                                        published_at: 3.hours.ago)
    article2 = create(TextArticle, profile_id: community.id, highlighted: true,
                                        published_at: 2.hours.ago)
    article3 = create(TextArticle, profile_id: community.id, highlighted: true,
                                        published_at: 1.hours.ago)

    env = Environment.default
    env.portal_community = community
    env.save!

    get :reorder, index: 2, direction: 'up'
    news = community.news(3, true)
    assert_equal [article3, article1, article2], news
  end

  should 'move an article down' do
    login_as @admin.identifier
    community = fast_create(Community)
    article1 = create(TextArticle, profile_id: community.id, highlighted: true,
                                        published_at: 3.hours.ago)
    article2 = create(TextArticle, profile_id: community.id, highlighted: true,
                                        published_at: 2.hours.ago)
    article3 = create(TextArticle, profile_id: community.id, highlighted: true,
                                        published_at: 1.hours.ago)

    env = Environment.default
    env.portal_community = community
    env.save!

    get :reorder, index: 0, direction: 'down'
    news = community.news(3, true)
    assert_equal [article2, article3, article1], news
  end
end
