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
  map.connect 'account/:action', :controller => 'account'

  # profile customization
  map.connect 'customize/:profile/edit_template/:action/:id', :controller => 'edit_template'

  # content administration
  map.comatose_admin 'cms/:profile'

  # administrative tasks for a virtual community
  map.connect 'admin/:controller/:action/:id'


  # *content viewing*
  # XXX this route must come last so other tasks have priority over it.
  map.connect ':profile/*page', :controller => 'content_viewer', :action => 'view_page'

  # no default route
  # map.connect ':controller/:action/:id'

end
