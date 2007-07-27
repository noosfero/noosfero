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

  # user account controller
  map.connect 'account/:action', :controller => 'account'
  map.connect 'doc', :controller => 'doc'

  # administrative tasks for a virtual community
  map.connect 'admin/:controller/:action/:id'

  # profile customization for profiles
  map.connect 'customize/:profile/:controller/:action/:id'

  # content viewwing:
  map.connect ':profile/*page', :controller => 'content_viewer', :action => 'view_page'

  # Install the default route as the lowest priority.
  map.connect ':controller/:action/:id'

  # TODO: comatose here

end
