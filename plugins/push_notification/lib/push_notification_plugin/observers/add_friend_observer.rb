module PushNotificationPlugin::Observers
  module AddFriendObserver
    def add_friend_after_create_callback(add_friend)
      requestor = add_friend.requestor
      target = add_friend.target

      send_to_users("add_friend",
                    [target.user],
                    {:event => "Add Friend",
                     :requestor_id => requestor.id,
                     :requestor_name => requestor.name,
                     :task_id => add_friend.id}
                   )
    end

    #check when task is finished
    def add_friend_after_save_callback(add_friend)
      requestor = add_friend.requestor
      target = add_friend.target

      return false unless [Task::Status::FINISHED, Task::Status::CANCELLED].include?(add_friend.status)

      added = add_friend.status==Task::Status::FINISHED
      event= added ? "Friendship accepted" : "Friendship refused"

      send_to_users("add_friend_result",
                    [requestor.user],
                    {:event => event,
                     :target_id => target.id,
                     :target_name => target.name,
                     :task_id => add_friend.id}
                   )
    end
  end
end
