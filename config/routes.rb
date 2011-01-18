require 'noosfero'

ActionController::Routing::Routes.draw do |map|
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

  map.connect 'test/:controller/:action/:id'  , :controller => /.*test.*/
 
  # -- just remember to delete public/index.html.
  # You can have the root of your site routed by hooking up ''
  map.connect '', :controller => "home", :conditions => { :if => lambda { |env| !Domain.hosting_profile_at(env[:host]) } }

  map.connect 'images/*stuff', :controller => 'not_found', :action => 'index'
  map.connect 'stylesheets/*stuff', :controller => 'not_found', :action => 'index'
  map.connect 'designs/*stuff', :controller => 'not_found', :action => 'index'
  map.connect 'articles/*stuff', :controller => 'not_found', :action => 'index'
  map.connect 'javascripts/*stuff', :controller => 'not_found', :action => 'index'
  map.connect 'thumbnails/*stuff', :controller => 'not_found', :action => 'index'
  map.connect 'user_themes/*stuff', :controller => 'not_found', :action => 'index'

  # online documentation
  map.doc         'doc', :controller => 'doc', :action => 'index'
  map.doc_section 'doc/:section', :controller => 'doc', :action => 'section'
  map.doc_topic   'doc/:section/:topic', :controller => 'doc', :action => 'topic'
  
  # user account controller
  map.connect 'account/new_password/:code', :controller => 'account', :action => 'new_password'
  map.connect 'account/:action', :controller => 'account'

  # enterprise registration
  map.connect 'enterprise_registration/:action', :controller => 'enterprise_registration'

  # tags
  map.tag 'tag', :controller => 'search', :action => 'tags'
  map.tag 'tag/:tag', :controller => 'search', :action => 'tag', :tag => /.*/
  
  # categories index
  map.category 'cat/*category_path', :controller => 'search', :action => 'category_index'
  map.assets 'assets/:asset/*category_path', :controller => 'search', :action => 'assets'
  # search
  map.connect 'search/:action/*category_path', :controller => 'search'
 
  # Browse
  map.connect 'browse/:action/:filter', :controller => 'browse'
  map.connect 'browse/:action', :controller => 'browse'

  # events
  map.events 'profile/:profile/events_by_day', :controller => 'events', :action => 'events_by_day', :profile => /#{Noosfero.identifier_format}/
  map.events 'profile/:profile/events/:year/:month/:day', :controller => 'events', :action => 'events', :year => /\d*/, :month => /\d*/, :day => /\d*/, :profile => /#{Noosfero.identifier_format}/
  map.events 'profile/:profile/events/:year/:month', :controller => 'events', :action => 'events', :year => /\d*/, :month => /\d*/, :profile => /#{Noosfero.identifier_format}/
  map.events 'profile/:profile/events', :controller => 'events', :action => 'events', :profile => /#{Noosfero.identifier_format}/

  # catalog
  map.catalog 'catalog/:profile', :controller => 'catalog', :action => 'index', :profile => /#{Noosfero.identifier_format}/

  # invite
  map.invite 'profile/:profile/invite/friends', :controller => 'invite', :action => 'select_address_book', :profile => /#{Noosfero.identifier_format}/
  map.invite 'profile/:profile/invite/:action', :controller => 'invite', :profile => /#{Noosfero.identifier_format}/

  # feeds per tag
  map.tag_feed 'profile/:profile/tags/:id/feed', :controller => 'profile', :action =>'tag_feed', :id => /.+/, :profile => /#{Noosfero.identifier_format}/

  # profile tags
  map.tag 'profile/:profile/tags/:id', :controller => 'profile', :action => 'content_tagged', :id => /.+/, :profile => /#{Noosfero.identifier_format}/
  map.tag 'profile/:profile/tags', :controller => 'profile', :action => 'tags', :profile => /#{Noosfero.identifier_format}/

  # profile search
  map.profile_search 'profile/:profile/search', :controller => 'profile_search', :action => 'index', :profile => /#{Noosfero.identifier_format}/

  # public profile information
  map.profile 'profile/:profile/:action/:id', :controller => 'profile', :action => 'index', :id => /.*/, :profile => /#{Noosfero.identifier_format}/

  # contact
  map.contact 'contact/:profile/:action/:id', :controller => 'contact', :action => 'index', :id => /.*/, :profile => /#{Noosfero.identifier_format}/

  # chat
  map.chat 'chat/:action/:id', :controller => 'chat'
  map.chat 'chat/:action', :controller => 'chat'

  ######################################################
  ## Controllers that are profile-specific (for profile admins )
  ######################################################
  # profile customization - "My profile"
  map.myprofile 'myprofile/:profile', :controller => 'profile_editor', :action => 'index', :profile => /#{Noosfero.identifier_format}/
  map.myprofile 'myprofile/:profile/:controller/:action/:id', :controller => Noosfero.pattern_for_controllers_in_directory('my_profile'), :profile => /#{Noosfero.identifier_format}/


  ######################################################
  ## Controllers that are used by environment admin
  ######################################################
  # administrative tasks for a environment
  map.admin 'admin', :controller => 'admin_panel'
  map.admin 'admin/:controller.:format/:action/:id', :controller => Noosfero.pattern_for_controllers_in_directory('admin')
  map.admin 'admin/:controller/:action/:id', :controller => Noosfero.pattern_for_controllers_in_directory('admin')


  ######################################################
  ## Controllers that are used by system admin
  ######################################################
  # administrative tasks for a environment
  map.system 'system', :controller => 'system'
  map.system 'system/:controller/:action/:id', :controller => Noosfero.pattern_for_controllers_in_directory('system')

  ######################################################
  # plugin routes
  ######################################################
  plugins_routes = File.join(Rails.root + '/lib/noosfero/plugin/routes.rb')
  eval(IO.read(plugins_routes), binding, plugins_routes)

  # cache stuff - hack
  map.cache 'public/:action/:id', :controller => 'public'

  # match requests for profiles that don't have a custom domain
  map.homepage ':profile/*page', :controller => 'content_viewer', :action => 'view_page', :profile => /#{Noosfero.identifier_format}/, :conditions => { :if => lambda { |env| !Domain.hosting_profile_at(env[:host]) } }

  # match requests for content in domains hosted for profiles
  map.connect '*page', :controller => 'content_viewer', :action => 'view_page'

end
