require 'test_helper'

class MailingListPluginAdminControllerTest < ActionController::TestCase

  def setup
    @admin = create_admin_user(Environment.default)
    login_as(@admin)

    @client = mock
    @client.stubs(:login)
    Mail::Sympa.stubs(:new).returns(@client)
  end

  should 'display the connection status' do
    get :index
    assert_tag 'span', attributes: { class: 'connection up' }

    Mail::Sympa.stubs(:new).raises(StandardError)
    get :index
    assert_tag 'span', attributes: { class: 'connection down' }
  end

  should 'not display any urls if the settings were not defined' do
    get :index
    assert_tag tag: 'td', content: '',
               ancestor: { tag: 'tr', attributes: { class: 'api-url' } }
    assert_tag tag: 'td', content: '',
               ancestor: { tag: 'tr', attributes: { class: 'web-interface-url' } }
  end

  should 'enable manage buttons if connection is up' do
    get :index
    assert_no_tag tag: 'a', attributes: { class: /.*button icon-menu-community.*disabled.*/ }
    assert_no_tag tag: 'a', attributes: { class: /.*button icon-menu-enterprise.*disabled.*/ }
  end

  should 'not enable manage buttons if connection is down' do
    Mail::Sympa.stubs(:new).raises(RuntimeError)
    get :index
    assert_tag tag: 'a', attributes: { class: /.*button icon-menu-community.*disabled.*/ }
    assert_tag tag: 'a', attributes: { class: /.*button icon-menu-enterprise.*disabled.*/ }
  end

  should 'redirect to index when opening manage pages and connection is down' do
    MailingListPlugin::Client.stubs(:new).raises(RuntimeError)

    get :manage_communities
    assert_redirected_to action: :index

    get :manage_enterprises
    assert_redirected_to action: :index
  end

  should 'display all communities that are not templates' do
    @client.stubs(:complex_lists).returns([])
    community1 = fast_create(Community, is_template: true)
    community2 = fast_create(Community)
    community3 = fast_create(Community)

    get :manage_communities
    assert_no_tag  'a', content: community1.name
    assert_tag  'a', content: community2.name
    assert_tag  'a', content: community3.name
  end

  should 'display all enterprises that are not templates' do
    @client.stubs(:complex_lists).returns([])
    enterprise1 = fast_create(Enterprise, is_template: true)
    enterprise2 = fast_create(Enterprise)
    enterprise3 = fast_create(Enterprise)

    get :manage_enterprises
    assert_no_tag  'a', content: enterprise1.name
    assert_tag  'a', content: enterprise2.name
    assert_tag  'a', content: enterprise3.name
  end

  should 'save settings if the connection could be established' do
    post :edit, settings: {
      api_url: 'http://api/url',
      web_interface_url: 'http://web/url',
      administrator_email: 'adm@mail.com',
      administrator_password: 'password'
    }

    env = Environment.default
    settings = Noosfero::Plugin::Settings.new(env, MailingListPlugin)
    assert_equal 'http://api/url', settings.api_url
    assert_equal 'http://web/url', settings.web_interface_url
    assert_equal 'adm@mail.com', settings.administrator_email
  end

  should 'not save settings if the connection could be established' do
    Mail::Sympa.stubs(:new).raises(StandardError)
    post :edit, settings: {
      api_url: 'http://api/url',
      web_interface_url: 'http://web/url',
      administrator_email: 'adm@mail.com',
      administrator_password: 'password'
    }

    env = Environment.default
    settings = Noosfero::Plugin::Settings.new(env, MailingListPlugin)
    assert_not_equal 'http://api/url', settings.api_url
    assert_not_equal 'http://api/url', settings.web_interface_url
    assert_not_equal 'adm@email.com', settings.administrator_email
  end

  should 'activate a list' do
    community = fast_create(Community)
    get :activate, id: community.id
    settings = Noosfero::Plugin::Settings.new(community, MailingListPlugin)
    community.reload
    assert settings.enabled
  end

  should 'deactivate a list' do
    community = fast_create(Community)
    settings = Noosfero::Plugin::Settings.new(community, MailingListPlugin)
    settings.enabled = true
    settings.save!

    get :deactivate, id: community.id
    community.reload
    refute settings.enabled
  end

  should 'activate all profiles of a kind that are not a template' do
    community1 = fast_create(Community, is_template: true)
    community2 = fast_create(Community)
    community3 = fast_create(Community)

    get :activate_all, kind: 'communities'
    settings = Noosfero::Plugin::Settings.new(community1, MailingListPlugin)
    community1.reload
    refute settings.enabled

    [community2, community3].each do |community|
      settings = Noosfero::Plugin::Settings.new(community, MailingListPlugin)
      community.reload
      assert settings.enabled
    end
  end

  should 'deactivate all profiles of a kind that are not a template' do
    community1 = fast_create(Community, is_template: true)
    community2 = fast_create(Community)
    community3 = fast_create(Community)
    [community1, community2, community3].each do |community|
      settings = Noosfero::Plugin::Settings.new(community, MailingListPlugin,
                                                enabled: true).save!
    end

    get :deactivate_all, kind: 'communities'
    settings = Noosfero::Plugin::Settings.new(community1, MailingListPlugin)
    community1.reload
    assert settings.enabled

    [community2, community3].each do |community|
      settings = Noosfero::Plugin::Settings.new(community, MailingListPlugin)
      community.reload
      refute settings.enabled
    end
  end

  should 'create a task when deploying all lists of a kind' do
    env = Environment.default
    settings = Noosfero::Plugin::Settings.new(env, MailingListPlugin)
    community1 = fast_create(Community, is_template: true)
    community2 = fast_create(Community)
    community3 = fast_create(Community)

    assert_difference 'Delayed::Job.count' do
      get :deploy_all, kind: 'communities'
      env.reload
      assert settings.deploying_communities
    end

    @client.stubs(:complex_lists).returns([])
    @client.stubs(:review).returns(['no_subscribers'])
    @client.expects(:create_list).times(2)
    @client.expects(:add).times(2)

    process_delayed_job_queue
    env.reload
    refute settings.deploying_communities
  end

  should 'not create a task if the environment is already deploying all lists' do
    assert_difference 'Delayed::Job.count' do
      get :deploy_all, kind: 'enterprises'
    end

    env = Environment.default
    settings = Noosfero::Plugin::Settings.new(env, MailingListPlugin)
    assert settings.deploying_enterprises
    refute settings.deploying_communities

    assert_no_difference 'Delayed::Job.count' do
      get :deploy_all, kind: 'enterprises'
    end

    assert_difference 'Delayed::Job.count' do
      get :deploy_all, kind: 'communities'
    end
  end

end
