Noosfero::Application.routes.draw do

  # user account controller
  match 'account/new_password/:code', controller: :account, action: :new_password, via: :all
  match 'account(/:action)', controller: :account, via: :all

end
