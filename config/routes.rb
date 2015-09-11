require_dependency 'noosfero'
require 'environment_domain_constraint'

Noosfero::Application.routes.draw do
  # The priority is based upon order of creation: first created -> highest priority.
  # Sample of regular route:
  # map.connect 'products/:id', controller: 'catalog', action: 'view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  # map.purchase 'products/:id/purchase', controller: 'catalog', action: 'purchase'
  # This route can be invoked with purchase_url(id: product.id)

  ######################################################
  ## Public controllers
  ######################################################

  match 'test/:controller(/:action(/:id))', controller: /.*test.*/, via: :all

  # -- just remember to delete public/index.html.
  # You can have the root of your site routed by hooking up ''
  root to: 'home#index', constraints: EnvironmentDomainConstraint.new, via: :all

  match 'site(/:action)', controller: 'home', via: :all
  match 'api(/:action)', controller: 'api', via: :all

  match 'images(/*stuff)', to: 'not_found#nothing', via: :all
  match 'stylesheets(/*stuff)', to: 'not_found#nothing', via: :all
  match 'designs(/*stuff)', to: 'not_found#nothing', via: :all
  match 'articles(/*stuff)', to: 'not_found#nothing', via: :all
  match 'javascripts(/*stuff)', to: 'not_found#nothing', via: :all
  match 'thumbnails(/*stuff)', to: 'not_found#nothing', via: :all
  match 'user_themes(/*stuff)', to: 'not_found#nothing', via: :all

  # embed controller
  match 'embed/:action/:id', controller: 'embed', id: /\d+/, via: :all

  # online documentation
  match 'doc', to: 'doc#index', as: :doc, via: :all
  match 'doc/:section', to: 'doc#section', as: :doc_section, via: :all
  match 'doc/:section/:topic', to: 'doc#topic', as: :doc_topic, via: :all

  # user account controller
  match 'account/new_password/:code', controller: 'account', action: 'new_password', via: :all
  match 'account(/:action)', controller: 'account', via: :all

  # enterprise registration
  match 'enterprise_registration(/:action)', controller: 'enterprise_registration', via: :all

  # tags
  match 'tag', controller: 'search', action: 'tags', via: :all
  match 'tag/:tag', controller: 'search', action: 'tag', tag: /.*/, via: :all

  # categories index
  match 'cat/*category_path', to: 'search#category_index', as: :category, via: :all
  # search
  match 'search(/:action(/*category_path))', controller: 'search', via: :all

  # events
  match 'profile/:profile/events_by_day', controller: 'events', action: 'events_by_day', profile: /#{Noosfero.identifier_format_in_url}/i, via: :all
  match 'profile/:profile/events_by_month', controller: 'events', action: 'events_by_month', profile: /#{Noosfero.identifier_format_in_url}/i, via: :all
  match 'profile/:profile/events/:year/:month/:day', controller: 'events', action: 'events', year: /\d*/, month: /\d*/, day: /\d*/, profile: /#{Noosfero.identifier_format_in_url}/i, via: :all
  match 'profile/:profile/events/:year/:month', controller: 'events', action: 'events', year: /\d*/, month: /\d*/, profile: /#{Noosfero.identifier_format_in_url}/i, via: :all
  match 'profile/:profile/events', controller: 'events', action: 'events', profile: /#{Noosfero.identifier_format_in_url}/i, via: :all

  # catalog
  match 'catalog/:profile', controller: 'catalog', action: 'index', profile: /#{Noosfero.identifier_format_in_url}/i, as: :catalog, via: :all

  # invite
  match 'profile/:profile/invite/friends', controller: 'invite', action: 'invite_friends', profile: /#{Noosfero.identifier_format_in_url}/i, via: :all
  match 'profile/:profile/invite/:action', controller: 'invite', profile: /#{Noosfero.identifier_format_in_url}/i, via: :all

  # feeds per tag
  match 'profile/:profile/tags/:id/feed', controller: 'profile', action:'tag_feed', id: /.+/, profile: /#{Noosfero.identifier_format_in_url}/i, as: :tag_feed, via: :all

  # profile tags
  match 'profile/:profile/tags/:id', controller: 'profile', action: 'content_tagged', id: /.+/, profile: /#{Noosfero.identifier_format_in_url}/i, via: :all
  match 'profile/:profile/tags(/:id)', controller: 'profile', action: 'tags', profile: /#{Noosfero.identifier_format_in_url}/i, via: :all

  # profile search
  match 'profile/:profile/search', controller: 'profile_search', action: 'index', profile: /#{Noosfero.identifier_format_in_url}/i, via: :all

  # comments
  match 'profile/:profile/comment/:action/:id', controller: 'comment', profile: /#{Noosfero.identifier_format_in_url}/i, via: :all

  # public profile information
  match 'profile/:profile(/:action(/:id))', controller: 'profile', action: 'index', id: /[^\/]*/, profile: /#{Noosfero.identifier_format_in_url}/i, as: :profile, via: :all

  # contact
  match 'contact/:profile/:action(/:id)', controller: 'contact', action: 'index', id: /.*/, profile: /#{Noosfero.identifier_format_in_url}/i, via: :all

  # map balloon
  match 'map_balloon/:action/:id', controller: 'map_balloon', id: /.*/, via: :all

  # chat
  match 'chat(/:action(/:id))', controller: 'chat', via: :all

  ######################################################
  ## Controllers that are profile-specific (for profile admins )
  ######################################################
  # profile customization - "My profile"
  match 'myprofile/:profile', controller: 'profile_editor', action: 'index', profile: /#{Noosfero.identifier_format_in_url}/i, via: :all
  match 'myprofile/:profile/:controller(/:action(/:id))', controller: Noosfero.pattern_for_controllers_in_directory('my_profile'), profile: /#{Noosfero.identifier_format_in_url}/i, as: :myprofile, via: :all


  ######################################################
  ## Controllers that are used by environment admin
  ######################################################
  # administrative tasks for a environment
  match 'admin', controller: 'admin_panel', action: :index, via: :all
  match 'admin/:controller(/:action((.:format)/:id))', controller: Noosfero.pattern_for_controllers_in_directory('admin'), via: :all
  match 'admin/:controller(/:action(/:id))', controller: Noosfero.pattern_for_controllers_in_directory('admin'), via: :all


  ######################################################
  ## Controllers that are used by system admin
  ######################################################
  # administrative tasks for a environment
  match 'system', controller: 'system', via: :all
  match 'system/:controller(/:action(/:id))', controller: Noosfero.pattern_for_controllers_in_directory('system'), via: :all

  ######################################################
  # plugin routes
  ######################################################
  plugins_routes = File.join(File.dirname(__FILE__) + '/../lib/noosfero/plugin/routes.rb')
  eval(IO.read(plugins_routes), binding, plugins_routes)

  # cache stuff - hack
  match 'public/:action/:id', controller: 'public', via: :all

  match ':profile/*page/versions', controller: 'content_viewer', action: 'article_versions', profile: /#{Noosfero.identifier_format_in_url}/i, constraints: EnvironmentDomainConstraint.new, via: :all
  match '*page/versions', controller: 'content_viewer', action: 'article_versions', via: :all

  match ':profile/*page/versions_diff', controller: 'content_viewer', action: 'versions_diff', profile: /#{Noosfero.identifier_format_in_url}/i, constraints: EnvironmentDomainConstraint.new, via: :all
  match '*page/versions_diff', controller: 'content_viewer', action: 'versions_diff', via: :all

  # match requests for profiles that don't have a custom domain
  match ':profile(/*page)', controller: 'content_viewer', action: 'view_page', profile: /#{Noosfero.identifier_format_in_url}/i, constraints: EnvironmentDomainConstraint.new, via: :all

  # match requests for content in domains hosted for profiles
  match '/(*page)', controller: 'content_viewer', action: 'view_page', via: :all


end
