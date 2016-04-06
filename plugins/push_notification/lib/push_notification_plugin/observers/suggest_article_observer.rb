module PushNotificationPlugin::Observers
  module SuggestArticleObserver
    def suggest_article_after_create_callback(suggest_article)
      requestor = suggest_article.requestor
      target = suggest_article.target

      if target.person?
        users = [target.user]
      elsif target.organization?
        users = target.admins.map{|person| person.user}
      end

      send_to_users("suggest_article",
                    users,
                    {:event => "Add Member",
                     :requestor_id => requestor.id,
                     :requestor_name => requestor.name,
                     :article => suggest_article.article,
                     :task_id => suggest_article.id}
                   )
    end

    def suggest_article_after_save_callback(suggest_article)
      requestor = suggest_article.requestor
      target = suggest_article.target

      return false unless [Task::Status::FINISHED, Task::Status::CANCELLED].include?(suggest_article.status)

      accepted = suggest_article.status==Task::Status::FINISHED
      event= accepted ? "Article approved" : "Article rejected"

      send_to_users("suggest_article_result",
                    [requestor],
                    {:event => event,
                     :target_id => target.id,
                     :target_name => target.name,
                     :article => suggest_article.article,
                     :task_id => suggest_article.id}
                   )
    end
  end
end
