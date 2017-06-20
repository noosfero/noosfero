module PushNotificationPlugin::Observers

  include ObserversHelper

  module ApproveArticleObserver
    def approve_article_after_create_callback(approve_article)
      target, requestor = get_target_and_requestor approve_article
      users = get_users_info target

      send_to_users("approve_article",
                    users,
                    {:event => "Approve Article",
                     :requestor_id => requestor.id,
                     :requestor_name => requestor.name,
                     :article => approve_article.article,
                     :task_id => approve_article.id}
                   )
    end

    def approve_article_after_save_callback(approve_article)
      requestor = approve_article.requestor
      target = approve_article.target

      return false unless [Task::Status::FINISHED, Task::Status::CANCELLED].include?(approve_article.status)

      accepted = approve_article.status==Task::Status::FINISHED
      event= accepted ? "Article approved" : "Article rejected"

      send_to_users("approve_article_result",
                    [requestor],
                    {:event => event,
                     :target_id => target.id,
                     :target_name => target.name,
                     :article => approve_article.article,
                     :task_id => approve_article.id}
                   )
    end
  end
end
