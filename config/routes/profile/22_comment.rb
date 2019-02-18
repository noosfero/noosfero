Noosfero::Application.routes.draw do

  scope :profile do
    scope ':profile', profile: /[^\/]+/ do
      resources :comment, only: [:create, :edit] do
        collection do
        end
    
        member do 
          post 'check_actions'
          post 'mark_as_spam'
          post 'update'
	  post 'destroy', as: 'destroy'
        end
      end
    end
  end

end
