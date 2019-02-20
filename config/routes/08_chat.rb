Noosfero::Application.routes.draw do

  resources :chat, only: [] do
    collection do 
      match '', to: 'chat#index', via: :get, as: :index
      match 'avatar/(:id)', to: 'chat#avatar', via: :get, as: :avatar
      get :start_session
      get :toggle
      post :tab
      post :join
      post :leave
      get :my_session
      get :avatars
      get :update_presence_status
      post :save_message
      get :recent_messages
      get :recent_conversations
      get :rosters
      get :availabilities
    end
  end

end
