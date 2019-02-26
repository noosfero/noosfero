Noosfero::Application.routes.draw do
  scope :profile do
    scope ':profile', profile: /[^\/]+/ do
      resources :profile_roles do
        collection do
        end
    
        member do 
	  get :assign
	  post :remove
	  post :define
        end
      end
    end
  end

end
