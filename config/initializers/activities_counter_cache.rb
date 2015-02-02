if Delayed::Backend::ActiveRecord::Job.table_exists? &&
  Delayed::Backend::ActiveRecord::Job.attribute_names.include?('queue')
  job = Delayed::Backend::ActiveRecord::Job.all :conditions => ['handler LIKE ?', "%ActivitiesCounterCacheJob%"]
  if job.blank?
    Delayed::Backend::ActiveRecord::Job.enqueue(ActivitiesCounterCacheJob.new, {:priority => -3})
  end
end
