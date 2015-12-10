module PushNotificationPlugin::Observers
  module CommentObserver
    def comment_after_create_callback(comment)
      users = comment.source.person_followers.map{|p| p.user}

      send_to_users("new_comment",
                    users,
                    {:event => "New Comment",
                     :article => comment.source.id,
                     :comment_body => comment.body,
                     :comment_title => comment.title,
                     :comment_name => comment.name,
                     :author => comment.author.name})
    end
  end
end
