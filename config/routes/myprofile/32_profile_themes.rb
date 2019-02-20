Noosfero::Application.routes.draw do

  scope :myprofile do
    scope ':profile', profile: /[^\/]+/ do
      resources :profile_themes, only: [:edit] do
        collection do
          match 'new', to: 'profile_themes#new', via: [:get, :post], as: :new
          match 'index', to: 'profile_themes#index', via: [:get, :post]
          get 'unset'
        end
    
        member do 
          match 'add_css', to: 'profile_themes#add_css', via: :all
          match 'add_image', to: 'profile_themes#add_image', via: :all

          post 'update_css'
          post 'start_test'
          post 'stop_test'
          post 'set_layout_template'

          get 'css_editor'
          get 'set'
        end
      end
    end
  end

end
