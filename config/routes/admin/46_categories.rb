Noosfero::Application.routes.draw do

  scope :admin do
#    match 'categories', to: 'catgories#index', via: [:get, :post]
    resources :categories, only:  [:index] do
      collection do
        match 'new', to: 'categories#new', via: [:get, :post], as: :new
	get :get_children
      end
      member do 
        match 'edit', to: 'categories#edit', via: [:get, :post]
	post :remove
      end
    end
  end

end
