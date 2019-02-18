Noosfero::Application.routes.draw do
  resources :profile do
    collection do
      scope ':profile' do
#        match '', to: 'profile#', via: :all
        match 'follow', to: 'profile#follow', via: [:get, :post]
        match 'join', to: 'profile#join', via: [:get, :post]
#        get :index
        get :about
        get :activities
        get :tags
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
        get :leave
#        get :
#        get :
#        get :
#        get :

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
        post :send_mail
#        post :
#        post :
#        post :

      end
    end

    member do 
      scope ':profile' do
        get :content_tagged
        get :tag_feed
      end
    end
  end

end
