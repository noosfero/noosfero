if Delayed::Backend::ActiveRecord::Job.table_exists? &&
  Delayed::Backend::ActiveRecord::Job.attribute_names.include?('queue')
  PersonNotifier.schedule_all_next_notification_mail
end
