Noosfero::Application.routes.draw do
  scope ':profile', profile: /[^\/]+/ do
    get '/*page/versions', to: 'content_viewer#article_versions', as: :versions
    get '/*page/versions_diff', to: 'content_viewer#versions_diff', as: :versions_diff
    get '/*page/view_more_comments', to: 'content_viewer#view_more_comments', as: :page_view_more_comments
    get '/(*page)', to: 'content_viewer#view_page', as: :page
  end

end
