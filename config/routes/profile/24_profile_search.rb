Noosfero::Application.routes.draw do
  scope :profile do
    scope ':profile', profile: /[^\/]+/ do
      resources :search, only: [] do
#      resources :search, path_names: { index: 'search' }, only: [:index] do
        collection do
          get '', to: 'profile_search#index', as: :index
        end
 
        member do 
        end
      end
    end
  end
end
