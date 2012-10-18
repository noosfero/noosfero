class SpaminatorPlugin::ScanJob < Struct.new(:environment_id)
  def perform
    fork do
      environment = Environment.find(environment_id)
      settings = Noosfero::Plugin::Settings.new(environment, SpaminatorPlugin)
      settings.scanning = true
      settings.save!

      SpaminatorPlugin::Spaminator.run(environment)

      settings.scanning = false
      SpaminatorPlugin.schedule_scan(environment) if settings.deployed
      settings.save!
    end
  end
end
