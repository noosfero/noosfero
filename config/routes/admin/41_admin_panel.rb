Noosfero::Application.routes.draw do

  scope :admin do
    get '', to: 'admin_panel#index' 
    resources :admin_panel, only: [:index]
  end


end
