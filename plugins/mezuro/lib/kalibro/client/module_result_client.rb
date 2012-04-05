class Kalibro::Client::ModuleResultClient

  def initialize
    @port = Kalibro::Client::Port.new('ModuleResult')
  end

  def module_result(project_name, module_name, date)
    hash = @port.request(:get_module_result,
      {:project_name => project_name, :module_name => module_name,
       :date => Kalibro::Entities::Entity.date_with_milliseconds(date)})[:module_result]
    Kalibro::Entities::ModuleResult.from_hash(hash)
  end

  def result_history(project_name, module_name)
    value = @port.request(:get_result_history,
      {:project_name => project_name, :module_name => module_name})[:module_result]
    Kalibro::Entities::Entity.new.to_entity_array(value, Kalibro::Entities::ModuleResult)
  end

  private

  def date_with_milliseconds(date)
    milliseconds = "." + (date.sec_fraction * 60 * 60 * 24 * 1000).to_s
    date.to_s[0..18] + milliseconds + date.to_s[19..-1]
  end

end
