Noosfero::Application.routes.draw do
  resources :profile, only: [] do
    collection do
      scope ':profile' do
        match 'tags', to: 'profile_design#content_tagged,', via: :all
      end
    end

    member do 
      scope ':profile' do
      end
    end
  end
end
