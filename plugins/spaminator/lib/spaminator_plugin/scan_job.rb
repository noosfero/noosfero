class SpaminatorPlugin::ScanJob < Struct.new(:environment_id)
  def perform
    fork {system("ruby #{File.join(SpaminatorPlugin.root_path, 'script', 'scan')} #{environment_id}") }
  end
end
