Noosfero::Application.routes.draw do
  scope :profile do
    scope ':profile', profile: /[^\/]+/ do
      resources :invite, only: [:create, :edit] do
        collection do
          match :friends, to: 'invite#invite_friends', via: [:get, :post]
          match :select_friends, to: 'invite#select_friends', via: [:get, :post]
	  get :invitation_data
	  get :add_contact_list
	  get :cancel_fetching_emails
	  post :invite_registered_friend
	  get :search
        end
    
        member do 
        end
      end
    end
  end

end
