Noosfero::Application.routes.draw do

  environment_domain_constraint = -> request { !Domain.hosting_profile_at(request.host) && !request.path.starts_with?('/myprofile') }

  match ':profile/*page/versions', controller: :content_viewer, action: :article_versions, profile: /#{Noosfero.identifier_format_in_url}/i, constraints: environment_domain_constraint, via: :all
  match '*page/versions', controller: :content_viewer, action: :article_versions, via: :all

  match ':profile/*page/versions_diff', controller: :content_viewer, action: :versions_diff, profile: /#{Noosfero.identifier_format_in_url}/i, constraints: environment_domain_constraint, via: :all
  match '*page/versions_diff', controller: :content_viewer, action: :versions_diff, via: :all

  # match requests for profiles that don't have a custom domain
  match ':profile(/*page)', controller: :content_viewer, action: :view_page, profile: /#{Noosfero.identifier_format_in_url}/i,
    constraints: environment_domain_constraint, via: :all, as: :page

  # match requests for content in domains hosted for profiles
  match '/(*page)', controller: :content_viewer, action: :view_page, via: :all, constraints: lambda { |request| !request.path.starts_with?('/myprofile') }

end
