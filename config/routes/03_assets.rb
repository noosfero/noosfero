Noosfero::Application.routes.draw do

  match 'images(/*stuff)', to: 'not_found#nothing', via: :all
  match 'stylesheets(/*stuff)', to: 'not_found#nothing', via: :all
  match 'designs(/*stuff)', to: 'not_found#nothing', via: :all
  match 'articles(/*stuff)', to: 'not_found#nothing', via: :all
  match 'javascripts(/*stuff)', to: 'not_found#nothing', via: :all
  match 'thumbnails(/*stuff)', to: 'not_found#nothing', via: :all
  match 'user_themes(/*stuff)', to: 'not_found#nothing', via: :all
  match 'urls-to-cache', to: 'public#urls_to_cache', via: :get
  match 'offline', to: 'public#offline', via: :get

end
