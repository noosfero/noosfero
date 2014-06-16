if Delayed::Backend::ActiveRecord::Job.table_exists?
  jobs = Delayed::Backend::ActiveRecord::Job.all :conditions => ['handler LIKE ?', "%LogMemoryConsumptionJob%"]
  jobs.map(&:destroy) if jobs.present?
  Delayed::Backend::ActiveRecord::Job.enqueue(LogMemoryConsumptionJob.new)
end
