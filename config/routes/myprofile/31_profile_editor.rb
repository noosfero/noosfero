Noosfero::Application.routes.draw do

  scope :myprofile do
    scope ':profile',  profile: /[^\/]+/ do
      get '', to: 'profile_editor#index'
      resources :profile_editor, only: [:index] do
        collection do
          match 'informations', to: 'profile_editor#informations', via: :all
          match 'privacy', to: 'profile_editor#privacy', via: :all
          match 'enable', to: 'profile_editor#enable', via: :all
          match 'header_footer', to: 'profile_editor#header_footer', via: :all
          match 'destroy_profile', to: 'profile_editor#destroy_profile', via: :all
          match 'welcome_page', to: 'profile_editor#welcome_page', via: :all
          match 'categories', to: 'profile_editor#categories', via: [:get, :post]
          match 'locality', to: 'profile_editor#locality', via: [:get, :post]
    
          get 'preferences'
          get 'update_categories'
          get 'regions'
#          get 'edit'
        
          get 'search_tags'
          get 'tags'
          get 'deactivate_profile'
          get 'activate_profile'
          get 'reset_private_token'

          post 'remote_edit'
          post 'disable'
        end
    
      end
    end
  end

end
