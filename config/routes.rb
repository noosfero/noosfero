require_dependency 'noosfero'
require 'environment_domain_constraint'

Noosfero::Application.routes.draw do
  # The priority is based upon order of creation: first created -> highest priority.
  # Sample of regular route:
  # map.connect 'products/:id', :controller => 'catalog', :action => 'view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  # map.purchase 'products/:id/purchase', :controller => 'catalog', :action => 'purchase'
  # This route can be invoked with purchase_url(:id => product.id)

  ######################################################
  ## Public controllers
  ######################################################

  match 'test/:controller(/:action(/:id))'  , :controller => /.*test.*/

  # -- just remember to delete public/index.html.
  # You can have the root of your site routed by hooking up ''
  root :to => 'home#index', :constraints => EnvironmentDomainConstraint.new

  match 'site(/:action)', :controller => 'home'
  match 'api(/:action)', :controller => 'api'

  match 'images(/*stuff)' => 'not_found#nothing'
  match 'stylesheets(/*stuff)' => 'not_found#nothing'
  match 'designs(/*stuff)' => 'not_found#nothing'
  match 'articles(/*stuff)' => 'not_found#nothing'
  match 'javascripts(/*stuff)' => 'not_found#nothing'
  match 'thumbnails(/*stuff)' => 'not_found#nothing'
  match 'user_themes(/*stuff)' => 'not_found#nothing'

  # embed controller
  match 'embed/:action/:id', :controller => 'embed', :id => /\d+/

  # online documentation
  match 'doc' => 'doc#index', :as => :doc
  match 'doc/:section' => 'doc#section', :as => :doc_section
  match 'doc/:section/:topic' => 'doc#topic', :as => :doc_topic

  # user account controller
  match 'account/new_password/:code' => 'account#new_password', :controller => 'account', :action => 'new_password'
  match 'account(/:action)', :controller => 'account'

  # enterprise registration
  match 'enterprise_registration(/:action)', :controller => 'enterprise_registration'

  # tags
  match 'tag', :controller => 'search', :action => 'tags'
  match 'tag/:tag', :controller => 'search', :action => 'tag', :tag => /.*/

  # categories index
  match 'cat/*category_path' => 'search#category_index', :as => :category
  # search
  match 'search(/:action(/*category_path))', :controller => 'search'

  # events
  match 'profile/:profile/events_by_day', :controller => 'events', :action => 'events_by_day', :profile => /#{Noosfero.identifier_format_in_url}/i
  match 'profile/:profile/events_by_month', :controller => 'events', :action => 'events_by_month', :profile => /#{Noosfero.identifier_format_in_url}/i
  match 'profile/:profile/events/:year/:month/:day', :controller => 'events', :action => 'events', :year => /\d*/, :month => /\d*/, :day => /\d*/, :profile => /#{Noosfero.identifier_format_in_url}/i
  match 'profile/:profile/events/:year/:month', :controller => 'events', :action => 'events', :year => /\d*/, :month => /\d*/, :profile => /#{Noosfero.identifier_format_in_url}/i
  match 'profile/:profile/events', :controller => 'events', :action => 'events', :profile => /#{Noosfero.identifier_format_in_url}/i

  # catalog
  match 'catalog/:profile', :controller => 'catalog', :action => 'index', :profile => /#{Noosfero.identifier_format_in_url}/i, :as => :catalog

  # invite
  match 'profile/:profile/invite/friends', :controller => 'invite', :action => 'invite_friends', :profile => /#{Noosfero.identifier_format_in_url}/i
  match 'profile/:profile/invite/:action', :controller => 'invite', :profile => /#{Noosfero.identifier_format_in_url}/i

  # feeds per tag
  match 'profile/:profile/tags/:id/feed', :controller => 'profile', :action =>'tag_feed', :id => /.+/, :profile => /#{Noosfero.identifier_format_in_url}/i, :as => :tag_feed

  # profile tags
  match 'profile/:profile/tags/:id', :controller => 'profile', :action => 'content_tagged', :id => /.+/, :profile => /#{Noosfero.identifier_format_in_url}/i
  match 'profile/:profile/tags(/:id)', :controller => 'profile', :action => 'tags', :profile => /#{Noosfero.identifier_format_in_url}/i

  # profile search
  match 'profile/:profile/search', :controller => 'profile_search', :action => 'index', :profile => /#{Noosfero.identifier_format_in_url}/i

  # comments
  match 'profile/:profile/comment/:action/:id', :controller => 'comment', :profile => /#{Noosfero.identifier_format_in_url}/i

  # public profile information
  match 'profile/:profile(/:action(/:id))', :controller => 'profile', :action => 'index', :id => /[^\/]*/, :profile => /#{Noosfero.identifier_format_in_url}/i, :as => :profile

  # contact
  match 'contact/:profile/:action(/:id)', :controller => 'contact', :action => 'index', :id => /.*/, :profile => /#{Noosfero.identifier_format_in_url}/i

  # map balloon
  match 'map_balloon/:action/:id', :controller => 'map_balloon', :id => /.*/

  # chat
  match 'chat(/:action(/:id))', :controller => 'chat'

  ######################################################
  ## Controllers that are profile-specific (for profile admins )
  ######################################################
  # profile customization - "My profile"
  match 'myprofile/:profile', :controller => 'profile_editor', :action => 'index', :profile => /#{Noosfero.identifier_format_in_url}/i
  match 'myprofile/:profile/:controller(/:action(/:id))', :controller => Noosfero.pattern_for_controllers_in_directory('my_profile'), :profile => /#{Noosfero.identifier_format_in_url}/i, :as => :myprofile


  ######################################################
  ## Controllers that are used by environment admin
  ######################################################
  # administrative tasks for a environment
  match 'admin', :controller => 'admin_panel', :action => :index
  match 'admin/:controller(/:action((.:format)/:id))', :controller => Noosfero.pattern_for_controllers_in_directory('admin')
  match 'admin/:controller(/:action(/:id))', :controller => Noosfero.pattern_for_controllers_in_directory('admin')


  ######################################################
  ## Controllers that are used by system admin
  ######################################################
  # administrative tasks for a environment
  match 'system', :controller => 'system'
  match 'system/:controller(/:action(/:id))', :controller => Noosfero.pattern_for_controllers_in_directory('system')

  ######################################################
  # plugin routes
  ######################################################
  plugins_routes = File.join(File.dirname(__FILE__) + '/../lib/noosfero/plugin/routes.rb')
  eval(IO.read(plugins_routes), binding, plugins_routes)

  # cache stuff - hack
  match 'public/:action/:id', :controller => 'public'

  match ':profile/*page/versions', :controller => 'content_viewer', :action => 'article_versions', :profile => /#{Noosfero.identifier_format_in_url}/i, :constraints => EnvironmentDomainConstraint.new
  match '*page/versions', :controller => 'content_viewer', :action => 'article_versions'

  match ':profile/*page/versions_diff', :controller => 'content_viewer', :action => 'versions_diff', :profile => /#{Noosfero.identifier_format_in_url}/i, :constraints => EnvironmentDomainConstraint.new
  match '*page/versions_diff', :controller => 'content_viewer', :action => 'versions_diff'

  # match requests for profiles that don't have a custom domain
  match ':profile(/*page)', :controller => 'content_viewer', :action => 'view_page', :profile => /#{Noosfero.identifier_format_in_url}/i, :constraints => EnvironmentDomainConstraint.new

  # match requests for content in domains hosted for profiles
  match '/(*page)', :controller => 'content_viewer', :action => 'view_page'


end
