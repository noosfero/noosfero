Noosfero::Application.routes.draw do

#  match 'admin', controller: :admin_panel, action: :index, via: :all
#  match 'admin/:controller(/:action((.:format)/:id))', controller: Noosfero.pattern_for_controllers_in_directory('admin'), via: :all
#  match 'admin/:controller(/:action(/:id))', controller: Noosfero.pattern_for_controllers_in_directory('admin'), via: :all

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
