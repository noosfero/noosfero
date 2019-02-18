Noosfero::Application.routes.draw do
  scope :profile do
    scope ':profile' do
      resources :circles, except: [:update, :show] do
        collection do
#          get :friends, to: 'invite#invite_friends'
	  post :xhr_create
#	  get :invitation_data
        end
    
        member do 
	  post :update
#	  post :destroy#, as: :destroy
        end
      end
    end
  end

end
