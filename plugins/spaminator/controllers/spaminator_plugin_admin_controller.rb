class SpaminatorPluginAdminController < AdminController
  append_view_path File.join(File.dirname(__FILE__) + '/../views')

  def index
    @settings ||= Noosfero::Plugin::Settings.new(environment, SpaminatorPlugin, params[:settings])
    @reports_count = SpaminatorPlugin::Report.from_environment(environment).count
    @reports = SpaminatorPlugin::Report.from_environment(environment).order('created_at desc').limit(3)
    @next_run = settings.period.to_i + ((settings.last_run || Date.today).to_date - Date.today)
    if request.post?
      settings.period = nil if settings.period.blank?
      settings.save!
      redirect_to :action => 'index'
    end
  end

  def deploy
    if !settings.deployed
      SpaminatorPlugin.schedule_scan(environment)
      settings.deployed = true
      settings.save!
    end
    redirect_to :action => 'index'
  end

  def withhold
    remove_scheduled_scan
    settings.deployed = false
    settings.save!
    redirect_to :action => 'index'
  end

  def scan
    if !settings.scanning
      settings.scanning = true
      settings.save!
      remove_scheduled_scan
      Delayed::Job.enqueue(SpaminatorPlugin::ScanJob.new(environment.id))
    end
    redirect_to :action => 'index'
  end

  def reports
    @reports = SpaminatorPlugin::Report.from_environment(environment).order('created_at desc')
  end

  private

  def settings
    @settings ||= Noosfero::Plugin::Settings.new(environment, SpaminatorPlugin)
  end

  def remove_scheduled_scan
    if settings.scheduled_scan
      Delayed::Job.find(settings.scheduled_scan).destroy
      settings.scheduled_scan = nil
      settings.save!
    end
  end

end

