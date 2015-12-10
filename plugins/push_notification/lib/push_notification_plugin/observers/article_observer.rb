module PushNotificationPlugin::Observers
  module ArticleObserver
    def article_after_create_callback(article)
      users=[]

      if article.profile.organization?
        article.profile.members.each do |person|
          users |= [person.user] if person.user.present?
        end
      elsif article.profile.person?
        users |= [article.profile.user] if article.profile.user.present?
      end

      send_to_users("new_article",
                    users,
                    {:event => "New article",
                     :article => article.id,
                     :article_body => article.body,
                     :article_title => article.title,
                     :article_name => article.name,
                     :author => article.author_name})
    end
  end
end
