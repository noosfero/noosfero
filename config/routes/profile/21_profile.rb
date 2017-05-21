Noosfero::Application.routes.draw do

  match ':profile/about', controller: :profile, action: :about, profile: /#{Noosfero.identifier_format_in_url}/i, via: :all
  match ':profile/activities', controller: :profile, action: :activities, profile: /#{Noosfero.identifier_format_in_url}/i, via: :all

  # events
  match 'profile/:profile/events_by_day', controller: :events, action: :events_by_day, profile: /#{Noosfero.identifier_format_in_url}/i, via: :all
  match 'profile/:profile/events_by_month', controller: :events, action: :events_by_month, profile: /#{Noosfero.identifier_format_in_url}/i, via: :all
  match 'profile/:profile/events/:year/:month/:day', controller: :events, action: :events, year: /\d*/, month: /\d*/, day: /\d*/, profile: /#{Noosfero.identifier_format_in_url}/i, via: :all
  match 'profile/:profile/events/:year/:month', controller: :events, action: :events, year: /\d*/, month: /\d*/, profile: /#{Noosfero.identifier_format_in_url}/i, via: :all
  match 'profile/:profile/events', controller: :events, action: :events, profile: /#{Noosfero.identifier_format_in_url}/i, via: :all

  # invite
  match 'profile/:profile/invite/friends', controller: :invite, action: :invite_friends, profile: /#{Noosfero.identifier_format_in_url}/i, via: :all
  match 'profile/:profile/invite/:action', controller: :invite, profile: /#{Noosfero.identifier_format_in_url}/i, via: :all

  # feeds per tag
  match 'profile/:profile/tags/:id/feed', controller: :profile, action: :tag_feed, id: /.+/, profile: /#{Noosfero.identifier_format_in_url}/i, as: :tag_feed, via: :all

  # profile tags
  match 'profile/:profile/tags/:id', controller: :profile, action: :content_tagged, id: /.+/, profile: /#{Noosfero.identifier_format_in_url}/i, via: :all
  match 'profile/:profile/tags(/:id)', controller: :profile, action: :tags, profile: /#{Noosfero.identifier_format_in_url}/i, via: :all

  # profile search
  match 'profile/:profile/search', controller: :profile_search, action: :index, profile: /#{Noosfero.identifier_format_in_url}/i,
    via: :all, as: :profile_search

  # comments
  match 'profile/:profile/comment/:action/:id', controller: :comment, profile: /#{Noosfero.identifier_format_in_url}/i, via: :all

  # public profile information
  match 'profile/:profile(/:action(/:id))', controller: :profile, action: :index, id: /[^\/]*/, profile: /#{Noosfero.identifier_format_in_url}/i, as: :profile, via: :all

end
