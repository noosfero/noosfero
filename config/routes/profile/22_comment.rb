Noosfero::Application.routes.draw do

  scope :profile do
    scope ':profile' do
      resources :comment, only: [:create, :edit] do
        collection do
#          match 'suggest_an_article', to: 'cms#suggest_an_article', via: [:get, :post]
#          match 'new', as: 'new', to: 'cms#new', via: [:get, :post]
#    
#          match 'upload_files', to: 'cms#upload_files', via: [:get, :post]
#          post 'media_upload'
#          post 'set_home_page'
#          get 'why_categorize'
#          get 'search'
#          get 'published_media_items'
#          get 'files'
#          get 'search_tags'
#          get 'update_categories'
#	  get 'search_article_privacy_exceptions'

        end
    
        member do 
#          match 'edit', to: 'cms#edit', via: [:get, :post]
#          match 'view', to: 'cms#view', via: [:get, :post]
#          match 'publish', to: 'cms#publish', via: [:get, :post]
          post 'check_actions'
          post 'mark_as_spam'
          post 'update'
	  post 'destroy', as: 'destroy'
        end
      end
    end
  end

end
