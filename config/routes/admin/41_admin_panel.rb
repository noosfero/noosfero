Noosfero::Application.routes.draw do

  scope :admin do
    resources :admin_panel, only: [:index]
  end


end
