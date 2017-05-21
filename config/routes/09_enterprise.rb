Noosfero::Application.routes.draw do

  # enterprise registration
  match 'enterprise_registration(/:action)', controller: :enterprise_registration, via: :all

end
