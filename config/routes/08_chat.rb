Noosfero::Application.routes.draw do

  resources :chat, only: [] do
    collection do 
      get :start_session
      get :toggle
      post :tab
      post :join
      post :leave
      get :my_session
      get :avatar
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
