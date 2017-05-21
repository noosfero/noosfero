Noosfero::Application.routes.draw do

  match 'chat(/:action(/:id))', controller: :chat, via: :all

end
