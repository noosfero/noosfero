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

  # You can have the root of your site routed by hooking up '' 
  # -- just remember to delete public/index.html.
  map.connect '', :controller => "home"

  # user account controller
  map.connect 'account/new_password/:code', :controller => 'account', :action => 'new_password'
  map.connect 'account/:action', :controller => 'account'

  # enterprise registration
  map.connect 'enterprise_registration/:action', :controller => 'enterprise_registration'

  # tags
  map.tag 'tag', :controller => 'search', :action => 'tags'
  map.tag 'tag/:tag', :controller => 'search', :action => 'tag'
  # categories index
  map.category 'cat/*category_path', :controller => 'search', :action => 'category_index'
  map.assets 'assets/:asset/*category_path', :controller => 'search', :action => 'assets'
  map.directory 'directory/:asset/:initial/*category_path', :controller => 'search', :action => 'directory'
  # search
  map.connect 'search/:action/*category_path', :controller => 'search'
 

  # public profile information
  map.profile 'profile/:profile/:action/:id', :controller => 'profile', :action => 'index'

  ######################################################
  ## Controllers that are profile-specific (for profile admins )
  ######################################################
  # profile customization - "My profile"
  map.myprofile 'myprofile/:profile', :controller => 'profile_editor', :action => 'index'
  map.myprofile 'myprofile/:profile/:controller/:action/:id', :controller => Noosfero.pattern_for_controllers_in_directory('my_profile')


  ######################################################
  ## Controllers that are used by environment admin
  ######################################################
  # administrative tasks for a environment
  map.admin 'admin', :controller => 'admin_panel'
  map.admin 'admin/:controller/:action/:id', :controller => Noosfero.pattern_for_controllers_in_directory('admin')


  ######################################################
  ## Controllers that are used by system admin
  ######################################################
  # administrative tasks for a environment
  map.system 'system', :controller => 'system'
  map.system 'system/:controller/:action/:id', :controller => Noosfero.pattern_for_controllers_in_directory('system')


  ######################################################
  ## Test controllers.
  ## FIXME: this should not be needed
  ######################################################
  map.connect 'test/:controller/:action/:id'  , :controller => /.*test.*/

  map.connect ':profile/catalog/:action/:id', :controller => 'catalog'
  

  # *content viewing*
  # XXX this route must come last so other routes have priority over it.
  map.homepage ':profile/*page', :controller => 'content_viewer', :action => 'view_page'

end
