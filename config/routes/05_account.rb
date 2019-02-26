Noosfero::Application.routes.draw do
  resources :account, only: [:index] do
    match 'activate', to: 'account#activate', via: :all, on: :collection
    match 'signup', to: 'account#signup', via: :all, on: :collection
    match 'forgot_password', to: 'account#forgot_password', via: :all, on: :collection
    match 'new_password', to: 'account#new_password', via: :all, on: :collection
    match 'new_password/:code', to: 'account#new_password', via: :all, on: :collection
    match 'activate_enterprise', to: 'account#activate_enterprise', via: :all, on: :collection
    match 'accept_terms', to: 'account#accept_terms', via: :all, on: :collection
    match 'login', to: 'account#login', via: :all, on: :collection
    match 'change_password', to: 'account#change_password', via: :all, on: :collection
  
    collection do
      match 'logout', to: 'account#logout', via: [:get, :post]
      get 'resend_activation_codes'
      get 'logout_popup'
      get 'login_popup'
      get 'activation_question'
      get 'welcome'
      get 'check_valid_name'
      get 'check_email'
      get 'user_data'
      get 'search_cities'
      get 'search_state'
    end
    
  end
  # match 'account(/:action)', controller: :account, via: :all
end


