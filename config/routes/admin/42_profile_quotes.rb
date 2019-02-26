Noosfero::Application.routes.draw do

  scope :admin do
    resources :profile_quotas, only:  [:index] do
      collection do
        match 'edit_class', to: 'profile_quotas#edit_class', via: :all
        delete 'reset_class'
      end
      member do 
        post 'edit_kind'
        post 'edit_profile'
        delete 'reset_kind'
        delete 'reset_profile'
      end
    end
  end

end
