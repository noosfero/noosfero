Noosfero::Application.routes.draw do
  environment_domain_constraint = -> request { !Domain.hosting_profile_at(request.host) && !request.path.starts_with?('/myprofile') }

# FIXME see the best way to map content_viewer
#  scope ':profile', profile: /[^\/]+/ do
#    get '/', to: 'content_viewer#view_page', as: :view_page
#    get '/*page/versions', to: 'content_viewer#article_versions', as: :versions
#    get '/*page/versions_diff', to: 'content_viewer#versions_diff', as: :versions_diff
#    get '/*page/view_more_comments', to: 'content_viewer#view_more_comments', as: :page_view_more_comments
#    get '/(*page)', to: 'content_viewer#view_page', as: :page, constraints: environment_domain_constraint
#  end
#
#  # match requests for content in domains hosted for profiles
#  match '/(*page)', to: 'content_viewer#view_page', via: :all, constraints: lambda { |request| !request.path.starts_with?('/myprofile') }
#  match '*page/versions', controller: :content_viewer, action: :article_versions, via: :all
#  match '*page/versions_diff', controller: :content_viewer, action: :versions_diff, via: :all
#  match '*page/view_more_comments', controller: :content_viewer, action: :view_more_comments, via: :all

   match ':profile/*page/versions', controller: :content_viewer, action: :article_versions, profile: /#{Noosfero.identifier_format_in_url}/i, constraints: environment_domain_constraint, via: :all, as: :versions
  match '*page/versions', controller: :content_viewer, action: :article_versions, via: :all

  match ':profile/*page/versions_diff', controller: :content_viewer, action: :versions_diff, profile: /#{Noosfero.identifier_format_in_url}/i, constraints: environment_domain_constraint, via: :all, as: :versions_diff
  match '*page/versions_diff', controller: :content_viewer, action: :versions_diff, via: :all

  match ':profile/*page/view_more_comments', controller: :content_viewer, action: :view_more_comments, profile: /#{Noosfero.identifier_format_in_url}/i, constraints: environment_domain_constraint, via: :all, as: :page_view_more_comments
  match '*page/view_more_comments', controller: :content_viewer, action: :view_more_comments, via: :all

  # match requests for profiles that don't have a custom domain
  match ':profile(/*page)', controller: :content_viewer, action: :view_page, profile: /#{Noosfero.identifier_format_in_url}/i, constraints: environment_domain_constraint, via: :all, as: :page

  # match requests for content in domains hosted for profiles
  match '/(*page)', controller: :content_viewer, action: :view_page, via: :all, constraints: lambda { |request| !request.path.starts_with?('/myprofile') }




end
