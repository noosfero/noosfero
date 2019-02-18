Noosfero::Application.routes.draw do
  scope :myprofile do
    scope ':profile' do
      resources :profile_email_templates do
        member do 
          get :show_parsed
        end
      end
    end
  end
end
