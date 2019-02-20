Noosfero::Application.routes.draw do
  match 'myprofile/:profile/(*page)', controller: :angular_theme, action: :index, profile: /#{Noosfero.identifier_format_in_url}/i, via: :get
end
