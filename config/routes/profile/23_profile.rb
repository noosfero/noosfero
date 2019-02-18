Noosfero::Application.routes.draw do
  resources :profile, param: :profile, only: []  do
    collection do
#      scope ':profile' do
#        match '', to: 'profile#', via: :all
#        get :leave
#        get :
#        get :
#        get :
#        get :

#        post :
#        post :
#        post :

#      end
    end

    member do 
        get :index
#      scope ':profile' do
        match 'send_mail', to: 'profile#send_mail', via: [:get, :post]
        match 'tags/:id/feed', to: 'profile#tag_feed,', via: :get
        get :tags
        get :tag_feed, via: :all, as: :tag_feed
        get :content_tagged


        match 'follow', to: 'profile#follow', via: [:get, :post]
        match 'leave', to: 'profile#leave', via: [:get, :post]
        match 'join', to: 'profile#join', via: [:get, :post]
        match 'tags/:id', to: 'profile#content_tagged,', via: :all

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
        get :join_not_logged
        get :check_membership
        get :find_profile_circles
        get :check_friendship
        get :unblock
        get :search_followed
        get :view_more_activities
        get :more_comments
        get :more_replies


        post :join_modal
        post :add
        post :unfollow
        post :follow_article
        post :unfollow_article
        post :leave_scrap
        post :leave_comment_on_activity
        post :remove_scrap
        post :remove_activity
        post :remove_notification
        post :report_abuse
        post :register_report
        post :remove_comment
#        post :send_mail
#        get 'tags/:tag_feed', as: :feed
#      end
    end
  end

end
