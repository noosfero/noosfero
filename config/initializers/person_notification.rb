if Delayed::Backend::ActiveRecord::Job.table_exists?
  PersonNotifier.schedule_all_next_notification_mail
end
