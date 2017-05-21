Noosfero::Application.routes.draw do

  ##
  # Keep products URL compatibility
  get 'catalog/:profile', to: redirect{ |params, request| "/profile/#{request.params[:profile]}/plugin/products/catalog" }
  get 'profile/:profile/catalog', to: redirect{ |params, request| "/profile/#{request.params[:profile]}/plugin/products/catalog" }
  get 'myprofile/:profile/manage_products(/:action(/:id))', to: (redirect do |params, request|
    "/profile/#{request.params[:profile]}/plugin/products/page/#{request.params[:action]}/#{request.params[:id]}"
  end)

end
