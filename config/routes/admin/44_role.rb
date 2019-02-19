Noosfero::Application.routes.draw do

  scope :admin do
    resources :role
  end

end
