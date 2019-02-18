Noosfero::Application.routes.draw do
  scope :profile do
    scope ':profile' do
      resources :invite, only: [:create, :edit] do
        collection do
          get :friends, to: 'invite#invite_friends'
	  post :select_friends
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
