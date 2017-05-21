Noosfero::Application.routes.draw do

  # tags
  match 'tag', controller: :search, action: :tags, via: :all
  match 'tag(/:tag)', controller: :search, action: :tag, tag: /.*/, via: :all

  # categories index
  match 'cat/*category_path', to: 'search#category_index', as: :category, via: :all
  # search
  match 'search(/:action(/*category_path))', controller: :search, via: :all, as: :search

end
