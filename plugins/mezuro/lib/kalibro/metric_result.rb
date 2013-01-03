class Kalibro::MetricResult < Kalibro::Model

  attr_accessor :id, :configuration, :value, :error

  def initialize(attributes={})
    value = attributes[:value]
    @value = (value == "NaN") ? attributes[:aggregated_value].to_f : value.to_f
    attributes.each do |field, value|
      if field!= :value and field!= :aggregated_value and self.class.is_valid?(field)
        send("#{field}=", value)
      end
    end
    @errors = []
  end

  def id=(value)
    @id = value.to_i
  end

  def configuration=(value)
    @configuration = Kalibro::MetricConfigurationSnapshot.to_object value
  end

  def metric_configuration_snapshot
    configuration
  end

  def error=(value)
    @error = Kalibro::Throwable.to_object value
  end
  
  def descendant_results
    self.class.request(:descendant_results_of, {:metric_result_id => self.id})[:descendant_result].to_a
  end

  def self.metric_results_of(module_result_id)
    response = request(:metric_results_of, {:module_result_id => module_result_id})[:metric_result]
    response = [] if response.nil?
    response = [response] if response.is_a?(Hash) 
    response.map {|metric_result| new metric_result}
  end

  def self.history_of(metric_name, module_result_id)
    response = self.request(:history_of_metric, {:metric_name => metric_name, :module_result_id => module_result_id})[:date_metric_result]
    response = [] if response.nil?
    response = [response] if response.is_a?(Hash) 
    response.map {|date_metric_result| Kalibro::DateMetricResult.new date_metric_result}
  end

end
