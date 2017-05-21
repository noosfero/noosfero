Noosfero::Application.routes.draw do

  # contact
  match 'contact(/:profile)/:action(/:id)', controller: :contact, action: :index, id: /.*/, profile: /#{Noosfero.identifier_format_in_url}/i, via: :all

end
