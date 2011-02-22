class MezuroPlugin::CalculateMetricsJob < Struct.new(:project_id)
  def perform
    project = MezuroPlugin::Project.find project_id
    project.calculate_metrics
  end
end

