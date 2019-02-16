#FIXME See if it's correct
Noosfero::Application.routes.draw do
  resources :profile do
    collection do
      scope ':profile' do
#        match 'tags', to: 'profile_design#content_tagged,', via: :all
#        match 'leo', to: 'profile_design#index', via: :all
        get :index
      end
    end

    member do 
      scope ':profile' do
      end
    end
  end
end
