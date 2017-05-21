Noosfero::Application.routes.draw do

  match 'map_balloon/:action/:id', controller: :map_balloon, id: /.*/, via: :all

end
