require_relative "../test_helper"

class RoutingTest < ActionDispatch::IntegrationTest

  def setup
    Domain.clear_cache
  end

  # home page
  ################################################################
  def test_homepage
    assert_routing('/', :controller => 'home', :action => 'index')
  end

  # user-targeted controllers (account/*, cms/*, customize/*)
  ################################################################
  def test_account_controller
    assert_routing('/account', :controller => 'account', :action => 'index')
  end

  def test_enterprise_registration_controller
    assert_routing('/enterprise_registration', :controller => 'enterprise_registration', :action => 'index')
    assert_routing('/enterprise_registration/lala', :controller => 'enterprise_registration', :action => 'lala')
  end

  def test_new_password
    assert_routing('/account/new_password/90dfhga7sadgd0as6saas', :controller => 'account', :action => 'new_password', :code => '90dfhga7sadgd0as6saas')
  end

  def test_cms
    assert_routing('/myprofile/ze/cms', :profile => 'ze', :controller => 'cms', :action => 'index')
  end

  def test_cms_when_identifier_has_a_dot
    assert_routing('/myprofile/ynternet.org/cms', :profile => 'ynternet.org', :controller => 'cms', :action => 'index')
  end

  def test_edit_template
    # FIXME: this is wrong
    assert_routing('/admin/edit_template', :controller => 'edit_template', :action => 'index')
  end

  def test_profile_editor
    assert_routing('/myprofile/ze', :profile => 'ze', :controller => 'profile_editor', :action => 'index')
  end

  def test_profile_editor_when_identifier_has_a_dot
    assert_routing('/myprofile/ynternet.org', :profile => 'ynternet.org', :controller => 'profile_editor', :action => 'index')
  end

  # environment administrative controllers (admin/*)
  ################################################################

  def test_admin_panel_controller
    assert_routing('/admin', :controller => 'admin_panel', :action => 'index')
  end

  def test_features_controller
    assert_routing('/admin/features', :controller => 'features', :action => 'index')
    assert_routing('/admin/features/update', :controller => 'features', :action => 'update')
  end

  def test_categories_management
    assert_routing('/admin/categories', :controller => 'categories', :action => 'index')
    assert_routing('/admin/categories/new', :controller => 'categories', :action => 'new')
    assert_routing('/admin/categories/edit/2', :controller => 'categories', :action => 'edit', :id => '2')
  end

  # platform administrative controllers (system/*)
  ################################################################

  # external public controllers
  ################################################################
  def test_content_viewer

    # profile root:
    assert_routing('/ze', :controller => 'content_viewer', :action => 'view_page', :profile => 'ze')

    # some non-root page
    assert_routing('/ze/work/2007', :controller => 'content_viewer', :action => 'view_page', :profile => 'ze', :page => 'work/2007')
  end

  def test_category_browser
    assert_routing('/cat/products/eletronics', :controller => 'search', :action => 'category_index', :category_path => 'products/eletronics')
  end

  #FIXME remove this if design_blocks is not going to be used; or uncomment otherwise;
  #def test_routing_to_controllers_inside_design_blocks_directory
  #  assert_routing('/block/cojones/favorite_links_profile/show/1', :profile => 'cojones', :controller => 'favorite_links_profile', :action => 'show', :id => '1')
  #  assert_routing('/block/cojones/favorite_links_profile/save', :profile => 'cojones', :controller => 'favorite_links_profile', :action => 'save')

  #  assert_routing('/block/cojones/list_block/show/1', :profile => 'cojones', :controller => 'list_block', :action => 'show', :id => '1')
  #end

  def test_tag_viewing
    assert_routing('/tag', :controller => 'search', :action => 'tags')
    assert_routing('/tag/umboraminhaporra', :controller => 'search', :action => 'tag', :tag => 'umboraminhaporra')
  end

  def test_view_tag_with_dot
    assert_routing('/tag/tag.withdot', :controller => 'search', :action => 'tag', :tag => 'tag.withdot')
  end

  def test_profile_routing
    assert_routing('/profile/ze', :controller => 'profile', :profile => 'ze', :action => 'index')
    assert_routing('/profile/ze/friends', :controller => 'profile', :profile => 'ze', :action => 'friends')
  end

  def test_profile_with_dot_routing
    assert_routing('/profile/ze.withdot', :controller => 'profile', :action => 'index', :profile => 'ze.withdot')
  end

  def test_profile_with_dash_routing
    assert_routing('/profile/ze-withdash', :controller => 'profile', :action => 'index', :profile => 'ze-withdash')
  end

  def test_profile_with_underscore_routing
    assert_routing('/profile/ze_with_underscore', :controller => 'profile', :action => 'index', :profile => 'ze_with_underscore')
  end

  def test_profile_route_for_tags_with_dot
    assert_routing('/profile/ze/tags/tag.withdot', :controller => 'profile', :profile => 'ze', :action => 'content_tagged', :id => 'tag.withdot')
  end

  def test_profile_with_tilde_routing
    assert_routing('/profile/ze~withtilde', :controller => 'profile', :action => 'index', :profile => 'ze~withtilde')
  end

  def test_search_routing
    assert_routing('/search', :controller => 'search', :action => 'index')
  end

  def test_search_filter_routing
    assert_routing('/search/filter/a/b', :controller => 'search', :action => 'filter', :category_path => 'a/b')
  end

  def test_assets_routing
    assert_routing('/search/assets/a/b/c', :controller => 'search', :action => 'assets', :category_path => 'a/b/c')
  end

  def test_content_view_with_dot
    assert_routing('/ze.withdot', :controller => 'content_viewer', :action => 'view_page', :profile => 'ze.withdot')
  end

  def test_content_view_with_dash
    assert_routing('/ze-withdash', :controller => 'content_viewer', :action => 'view_page', :profile => 'ze-withdash')
  end

  def test_content_view_with_underscore
    assert_routing('/ze_with_underscore', :controller => 'content_viewer', :action => 'view_page', :profile => 'ze_with_underscore')
  end

  def test_content_view_with_tilde_routing
    assert_routing('/ze~withtilde', :controller => 'content_viewer', :action => 'view_page', :profile => 'ze~withtilde')
  end

  def test_catalog_routing
    assert_routing('/catalog/colivre', :controller => 'catalog', :action => 'index', :profile => 'colivre')
  end

  def test_hosted_domain_routing
    user = create_user('testuser').person
    domain = Domain.new(:name => 'example.com').tap { |d| d.owner = user; d.save! }

    ActionDispatch::Request.any_instance.stubs(:host).returns('www.example.com')

    assert_routing('/work/free-software', :controller => 'content_viewer', :action =>  'view_page', :page => 'work/free-software' )
  end

  def test_root_of_hosted_domain
    user = create_user('testuser').person
    domain = Domain.new(:name => 'example.com').tap { |d| d.owner = user; d.save! }

    ActionDispatch::Request.any_instance.stubs(:host).returns('www.example.com')

    assert_routing('', :controller => 'content_viewer', :action =>  'view_page')
  end

  def test_profile_under_hosted_domain
    community = Community.create!(:identifier => 'testcomm', :name => "test community")
    domain = Domain.new(:name => 'example.com').tap { |d| d.owner = community; d.save! }

    ActionDispatch::Request.any_instance.stubs(:host).returns('www.example.com')

    assert_routing('/profile/testcomm/refuse_for_now', :controller => 'profile', :action =>  'refuse_for_now', :profile => 'testcomm')
  end

  def test_must_not_route_as_profile_hosted_domain_for_domains_registered_for_environments
    environment = Environment.default
    domain = Domain.new(:name => 'example.com').tap { |d| d.owner = environment; d.save! }
    ActionDispatch::Request.any_instance.stubs(:host).returns('www.example.com')

    assert_routing('/', :controller => 'home', :action =>  'index')
  end

  def test_myprofile_with_dot
    assert_routing('/myprofile/profile.withdot', :controller => 'profile_editor', :action => 'index', :profile => 'profile.withdot')
  end

  def test_contact_routing
    assert_routing('/contact/wintermute/new', :controller => 'contact', :action => 'new', :profile => 'wintermute')
  end

  # online documentation routes
  def test_doc_routing_with_section_and_topic
    assert_routing('/doc/admin/settings', :controller => 'doc', :action => 'topic', :section => 'admin', :topic => 'settings')
  end
  def test_doc_routing_with_section_only
    assert_routing('/doc/admin', :controller => 'doc', :action => 'section', :section => 'admin')
  end
  def test_doc_routing_root
    assert_routing('/doc', :controller => 'doc', :action => 'index')
  end

  def test_invite_routing
    assert_routing('/profile/colivre/invite/friends', :controller => 'invite', :action => 'invite_friends', :profile => 'colivre')
  end

  def test_chat_routing
    assert_routing('/chat', :controller => 'chat', :action => 'index')
    assert_routing('/chat/avatar/chemical-brothers', :controller => 'chat', :action => 'avatar', :id => 'chemical-brothers')
  end

  def test_plugins_generic_routes
    assert_routing('/plugin/foo/public_bar/play/1', {:controller => 'foo_plugin_public_bar', :action => 'play', :id => '1'})
    assert_routing('/profile/test/plugin/foo/profile_bar/play/1', {:controller => 'foo_plugin_profile_bar', :action => 'play', :id => '1', :profile => 'test'})
    assert_routing('/myprofile/test/plugin/foo/myprofile_bar/play/1', {:controller => 'foo_plugin_myprofile_bar', :action => 'play', :id => '1', :profile => 'test'})
    assert_routing('/admin/plugin/foo/admin_bar/play/1', {:controller => 'foo_plugin_admin_bar', :action => 'play', :id => '1'})
  end

  def test_not_found_images_on_nothing
    assert_recognizes({:controller => 'not_found', :action => 'nothing', :stuff => 'aksdhf'}, '/images/aksdhf')
  end

  def test_not_found_stylesheets_on_nothing
    assert_recognizes({:controller => 'not_found', :action => 'nothing', :stuff => 'aksdhf'}, '/stylesheets/aksdhf')
  end

  def test_not_found_designs_on_nothing
    assert_recognizes({:controller => 'not_found', :action => 'nothing', :stuff => 'aksdhf'}, '/designs/aksdhf')
  end

  def test_not_found_articles_on_nothing
    assert_recognizes({:controller => 'not_found', :action => 'nothing', :stuff => 'aksdhf'}, '/articles/aksdhf')
  end

  def test_not_found_javascripts_on_nothing
    assert_recognizes({:controller => 'not_found', :action => 'nothing', :stuff => 'aksdhf'}, '/javascripts/aksdhf')
  end

  def test_not_found_thumbnails_on_nothing
    assert_recognizes({:controller => 'not_found', :action => 'nothing', :stuff => 'aksdhf'}, '/thumbnails/aksdhf')
  end

  def test_not_found_user_themes_on_nothing
    assert_recognizes({:controller => 'not_found', :action => 'nothing', :stuff => 'aksdhf'}, '/user_themes/aksdhf')
  end

  should 'have route to versions of an article' do

    assert_routing('/ze/work/free-software/versions', :controller => 'content_viewer', :action => 'article_versions', :profile => 'ze', :page => 'work/free-software')
  end

  should 'have route to versions of an article if profile has domain' do
    user = create_user('testuser').person
    domain = Domain.create!(:name => 'example.com', :owner => user)

    assert_routing('http://www.example.com/work/free-software/versions', :controller => 'content_viewer', :action =>  'article_versions', :page => 'work/free-software')
  end

  should 'have route to get HTML code of Blocks to embed' do
    assert_routing('/embed/block/12345', :controller => 'embed', :action => 'block', :id => '12345')
  end

  should 'accept ~ as placeholder for current user' do
    assert_routing('/profile/~', :controller => 'profile', :profile => '~', :action => 'index')
  end

end
