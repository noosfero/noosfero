Noosfero::Application.routes.draw do
  resources :profile, param: :profile,  profile: /[^\/]+/ , only: []  do
    collection do
    end

    member do 
        get :index
        match 'send_mail', to: 'profile#send_mail', via: [:get, :post]
        match 'tags/:id/feed', to: 'profile#tag_feed,', via: :get
        get :tags
        get :tag_feed, via: :all, as: :tag_feed
        get :content_tagged


        match 'follow', to: 'profile#follow', via: [:get, :post]
        match 'follow_article', to: 'profile#follow_article', via: [:get, :post]
        match 'unfollow', to: 'profile#unfollow', via: [:get, :post]
        match 'unfollow_article', to: 'profile#unfollow_article', via: [:get, :post]
        match 'report_abuse', to: 'profile#report_abuse', via: [:get, :post]
        match 'leave', to: 'profile#leave', via: [:get, :post]
        match 'join', to: 'profile#join', via: [:get, :post]
        match 'join_not_logged', to: 'profile#join_not_logged', via: [:get, :post]
        match 'tags/:id', to: 'profile#content_tagged', via: :all, id: /[^\/]+/
        match 'find_profile_circles', to: 'profile#find_profile_circles', via: [:get, :post]
        match 'unblock', to: 'profile#unblock', via: [:get, :post]
        match 'more_comments', to: 'profile#more_comments', via: [:get, :post]
        match 'more_replies', to: 'profile#more_replies', via: [:get, :post]
        match 'view_more_activities', to: 'profile#view_more_activities', via: [:get, :post]
        match 'join_modal', to: 'profile#join_modal', via: [:get, :post]
        match 'add', to: 'profile#add', via: [:get, :post]
        match 'leave_scrap', to: 'profile#leave_scrap', via: [:get, :post]
        match 'leave_comment_on_activity', to: 'profile#leave_comment_on_activity', via: [:get, :post]
        match 'remove_scrap', to: 'profile#remove_scrap', via: [:get, :post]
        match 'remove_activity', to: 'profile#remove_activity', via: [:get, :post]
        match 'remove_notification', to: 'profile#remove_notification', via: [:get, :post]
        match 'register_report', to: 'profile#register_report', via: [:get, :post]
        match 'remove_comment', to: 'profile#remove_comment', via: [:get, :post]

        get :about
        get :activities
        get :communities
        get :enterprises
        get :friends
        get :following
        get :followed
        get :members
        get :fans
        get :favorite_enterprises
        get :sitemap
        get :check_membership
        get :check_friendship
        get :search_followed

	# FIXME see if it's needed. See helper links_for_balloon
#        get :events
    end
  end

end
