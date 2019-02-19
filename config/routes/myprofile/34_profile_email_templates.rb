Noosfero::Application.routes.draw do
  scope :myprofile do
    scope ':profile', profile: /[^\/]+/ do
      resources :profile_email_templates do
        collection do 
          get :show_parsed
        end
        member do 
          get :show_parsed
        end
      end
    end
  end
end
