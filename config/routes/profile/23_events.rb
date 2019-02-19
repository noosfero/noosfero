Noosfero::Application.routes.draw do

  scope :profile do
    scope ':profile', profile: /[^\/]+/ do
      resources :events, only: [] do
        collection do
          match '', to: 'events#events', via: [:get, :post], as: ''
          get 'events_by_date'
          get 'events_by_month'
	  get ':year/:month/:day', to: 'events#events'
	  get ':year/:month', to: 'events#events'

        end
    
        member do 
        end
      end
    end
  end

end
