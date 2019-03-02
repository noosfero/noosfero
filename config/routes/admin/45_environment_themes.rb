Noosfero::Application.routes.draw do

  scope :admin do
    resources :environment_themes, only: [:index] do
      collection do
        get 'unset'
      end
  
      member do 
        post 'set_layout_template'
        get 'set'
      end
    end
  end

end
