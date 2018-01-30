Noosfero::Application.routes.draw do

  post '/push_subscriptions/create', controller: :push_subscriptions,
                                     action: :create

end
