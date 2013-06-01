class SpaminatorPlugin::Scan
  def self.run(environment_id)
    environment = Environment.find(environment_id)
    settings = Noosfero::Plugin::Settings.new(environment, SpaminatorPlugin)
    settings.scanning = true
    settings.save!

    begin
      SpaminatorPlugin::Spaminator.run(environment)
    rescue Exception => exception
      SpaminatorPlugin::Spaminator.log("Spaminator failed with the following error: \n ==> #{exception}\n#{exception.backtrace.join("\n")}")
    end

    settings.scanning = false
    SpaminatorPlugin.schedule_scan(environment) if settings.deployed
    settings.save!
  end
end
