require 'noosfero'

ActionController::Routing::Routes.draw do |map|
  # The priority is based upon order of creation: first created -> highest priority.
  
  # Sample of regular route:
  # map.connect 'products/:id', :controller => 'catalog', :action => 'view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  # map.purchase 'products/:id/purchase', :controller => 'catalog', :action => 'purchase'
  # This route can be invoked with purchase_url(:id => product.id)

  # You can have the root of your site routed by hooking up '' 
  # -- just remember to delete public/index.html.
  map.connect '', :controller => "home"

  # documentation browser
  map.connect 'doc', :controller => 'doc'

  # user account controller
  map.connect 'account/change_password/:hash', :controller => 'account', :action => 'change_password'

  map.connect 'account/:action', :controller => 'account'
 

  ######################################################
  ## Controllers that are profile-specific (for profile admins )
  ######################################################
  # profile customization - "My profile"
  map.myprofile 'myprofile/:profile', :controller => 'profile_editor', :action => 'index'
  map.myprofile 'myprofile/:profile/:controller/:action/:id', :controller => Noosfero.pattern_for_controllers_in_directory('profile_admin')
  # content administration 

  ######################################################
  ## Controllers that are used by environment admin
  ######################################################
  # administrative tasks for a environment
  map.admin 'admin', :controller => 'admin_panel'
  map.admin 'admin/:controller/:action/:id', :controller => Noosfero.pattern_for_controllers_in_directory('environment_admin')

  ######################################################
  ## Controllers that are used by system admin
  ######################################################
  # administrative tasks for a environment
  map.system 'system', :controller => 'system'
  map.system 'system/:controller/:action/:id', :controller => Noosfero.pattern_for_controllers_in_directory('system_admin')


  ######################################################
  ## Test controllers.
  ## FIXME: this should not be needed
  ######################################################
  map.connect 'test/:controller/:action/:id', :controller => /.*test.*/

  ######################################################
  ## Public controllers
  ######################################################
 
  map.connect 'cat', :controller => 'category', :action => 'index'
  map.category 'cat/*path', :controller => 'category', :action => 'view'

  # *content viewing*
  # XXX this route must come last so other routes have priority over it.
  map.homepage ':profile/*page', :controller => 'content_viewer', :action => 'view_page'

end
