Noosfero::Application.routes.draw do

  scope :admin do
      resources :environment_design, only: [:index] do
        collection do
          # FIXME this route should be on member
          match 'move_block', to: 'environment_design#move_block', via: :all
    
          get 'show_block_type_info'
          get 'search_autocomplete'
        end
    
        member do 
          post 'remove'
    
          post 'move_block_up'
          post 'move_block_down'
          post 'save'
          post 'clone_block'
    
          get 'update_categories'
          get 'edit'
        end
      end
  end


end
