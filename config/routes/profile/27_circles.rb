Noosfero::Application.routes.draw do
  scope :profile do
    scope ':profile', profile: /[^\/]+/ do
      resources :circles, except: [:update, :show] do
        collection do
	  post :xhr_create
        end
    
        member do 
	  post :update
        end
      end
    end
  end

end
