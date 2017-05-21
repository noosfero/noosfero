Noosfero::Application.routes.draw do

  environment_domain_constraint = -> request { !Domain.hosting_profile_at(request.host) }

  # -- just remember to delete public/index.html.
  # You can have the root of your site routed by hooking up ''
  root to: 'home#index', constraints: environment_domain_constraint, via: :all

  match 'site(/:action)', controller: :home, via: :all
  match 'api(/:action)', controller: :api, via: :all

  match 'embed/:action/:id', controller: :embed, id: /\d+/, via: :all

end
