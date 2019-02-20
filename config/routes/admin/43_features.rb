Noosfero::Application.routes.draw do

  scope :admin do
    resources :features, only:  [] do
      collection do
        match 'update', to: 'features#update', via: [:get, :post], as: :update
        match 'index', to: 'features#index', via: [:get, :post]
        get :manage_fields
	post :manage_person_fields
	post :manage_enterprise_fields
	post :manage_community_fields
	post :manage_custom_fields
	get :search_members
      end
      member do 
      end
    end
  end

end
