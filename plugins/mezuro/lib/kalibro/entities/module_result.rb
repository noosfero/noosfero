class Kalibro::Entities::ModuleResult < Kalibro::Entities::Entity

  attr_accessor :module, :date, :grade, :metric_result, :compound_metric_with_error

  def module=(value)
    @module = to_entity(value, Kalibro::Entities::Module)
  end

  def date=(value)
    @date = value
    @date = DateTime.parse(value) if value.is_a?(String)
  end

  def grade=(value)
    @grade = value.to_f
  end

  def metric_result=(value)
    @metric_result = to_entity_array(value, Kalibro::Entities::MetricResult)
  end

  def metric_results
    @metric_result
  end

  def metric_results=(metric_results)
    @metric_result = metric_results
  end

  def compound_metric_with_error=(value)
    @compound_metric_with_error = to_entity_array(value, Kalibro::Entities::CompoundMetricWithError)
  end

  def compound_metrics_with_error
    @compound_metric_with_error
  end

  def compound_metrics_with_error=(compound_metrics_with_error)
    @compound_metric_with_error = compound_metrics_with_error
  end
  
end