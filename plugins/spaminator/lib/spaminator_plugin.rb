class SpaminatorPlugin < Noosfero::Plugin

  def self.plugin_name
    "Spaminator"
  end

  def self.plugin_description
    _("Search and destroy spams and spammers.")
  end

  def self.period_default_setting
    30
  end

  def self.schedule_scan(environment)
    settings = Noosfero::Plugin::Settings.new(environment, self)
    if !settings.scanning
      job = Delayed::Job.enqueue(SpaminatorPlugin::ScanJob.new(environment.id), :run_at => settings.period.to_i.days.from_now)
      settings.scheduled_scan = job.id
      settings.save!
    end
  end

  def stylesheet?
    true
  end

end
