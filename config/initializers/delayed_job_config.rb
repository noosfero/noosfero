require 'delayed_job'
Delayed::Worker.backend = :active_record
Delayed::Worker.max_attempts = 2
Delayed::Worker.destroy_failed_jobs = false
Delayed::Worker.logger = Logger.new(File.join(Rails.root, 'log', 'delayed_job.log'))

class Delayed::Job
  def self.handler_like(handler)
    Delayed::Job.where("handler LIKE '%#{handler}%'")
  end

  def self.by_handler(handler)
    Delayed::Job.where(:handler => handler)
  end
end

# TODO This is consuming ton of space on development with a postgres connection
# error on the jobs. This must be verified before going into production.
# Logging jobs backtraces
#class Delayed::Worker
#  def handle_failed_job_with_loggin(job, error)
#    handle_failed_job_without_loggin(job,error)
#    Delayed::Worker.logger.error(error.message)
#    Delayed::Worker.logger.error(error.backtrace.join("\n"))
#  end
#  alias_method_chain :handle_failed_job, :loggin
#end

# Chain delayed job's handle_failed_job method to do exception notification
Delayed::Worker.class_eval do
  def handle_failed_job_with_notification job, error
    handle_failed_job_without_notification job, error
    ExceptionNotifier.notify_exception error, exception_recipients: NOOSFERO_CONF['exception_recipients'],
      data: {job: job, handler: job.handler} rescue nil
  end
  alias_method_chain :handle_failed_job, :notification
end
