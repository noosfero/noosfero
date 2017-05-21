Noosfero::Application.routes.draw do

  match 'test/:controller(/:action(/:id))', controller: /.*test.*/, via: :all

end
