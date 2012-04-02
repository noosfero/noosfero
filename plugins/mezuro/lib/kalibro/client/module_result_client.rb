class Kalibro::Client::ModuleResultClient

  # TODO test this
  def self.module_result(project_content, module_name)
    project_result = project_content.project_result
    new.module_result(project_result.project.name, module_name, project_result.date)
  end
  
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

end