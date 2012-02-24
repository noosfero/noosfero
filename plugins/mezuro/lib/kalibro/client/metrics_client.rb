class Kalibro::Client::MetricsClient

  def self.all_metrics
    [Kalibro::Entities::Metric.new("LOC", "class", "Lines of code", 1), 
    Kalibro::Entities::Metric.new("LCOM", "class", "Lack of cohesion", 2)]
  end

end
