module PushNotificationPlugin::Observers
  module AddMemberObserver
    def add_member_after_create_callback(add_member)
      requestor = add_member.requestor
      target = add_member.target

      users = target.admins.map{|person| person.user}

      send_to_users("add_member",
                    users,
                    {:event => "Add Member to Organization",
                     :requestor_id => requestor.id,
                     :requestor_name => requestor.name,
                     :task_id => add_member.id}
                   )
    end

    def add_member_after_save_callback(add_member)
      requestor = add_member.requestor
      target = add_member.target

      return false unless [Task::Status::FINISHED, Task::Status::CANCELLED].include?(add_member.status)

      accepted = add_member.status==Task::Status::FINISHED
      event= accepted ? "Membership accepted" : "Membership rejected"

      send_to_users("add_member_result",
                    [requestor],
                    {:event => event,
                     :target_id => target.id,
                     :target_name => target.name,
                     :task_id => add_member.id}
                   )
    end
  end
end
