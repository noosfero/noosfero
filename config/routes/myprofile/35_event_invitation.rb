Noosfero::Application.routes.draw do
  scope :myprofile do
    scope ':profile', profile: /[^\/]+/ do
      resources :event_invitation, only: [] do
#      resources :search, path_names: { index: 'search' }, only: [:index] do
        collection do
          post 'change_invitation_decision', to: 'event_invitation#change_invitation_decision'
        end
 
        member do 
        end
      end
    end
  end
end
