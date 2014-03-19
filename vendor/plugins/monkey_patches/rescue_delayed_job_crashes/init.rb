Delayed::Worker.module_eval do
  # based on https://groups.google.com/forum/#!topic/delayed_job/ZGMUFFppNgs
  class Delayed::Worker::ExceptionNotification < ActionMailer::Base
    def mail job, error
      environment = Environment.default

      recipients NOOSFERO_CONF['exception_recipients']
      from       environment.noreply_email
      reply_to   environment.noreply_email
      subject    "[#{environment.name}] DelayedJob ##{job.id}: #{error.message}"
      body       render(:text => "
Job:
#{job.inspect}

Handler:
#{job.handler}

Backtrace:
#{error.backtrace.join("\n")}
      ")
    end
  end

  def handle_failed_job_with_notification(job, error)
    Delayed::Worker::ExceptionNotification.deliver_mail job, error if NOOSFERO_CONF['exception_recipients'].present?
    handle_failed_job_without_notification job, error
  end
  alias_method_chain :handle_failed_job, :notification

  def handle_failed_job_with_rescue(job, error)
    handle_failed_job_without_rescue(job, error)
  rescue => e # don't crash here
  end
  alias_method_chain :handle_failed_job, :rescue

  protected

  # This code must be replicated because there is no other way to pass the job
  # through and use alias_method_chain as we used on the previous method
  def reserve_and_run_one_job
    # We get up to 5 jobs from the db. In case we cannot get exclusive access to a job we try the next.
    # this leads to a more even distribution of jobs across the worker processes
    job = Delayed::Job.find_available(name, 5, self.class.max_run_time).detect do |job|
      if job.lock_exclusively!(self.class.max_run_time, name)
        say "acquired lock on #{job.name}"
        true
      else
        say "failed to acquire exclusive lock for #{job.name}", Logger::WARN
        false
      end
    end

    run(job) if job
  rescue => e
    handle_failed_job(job, e)
  end
end
