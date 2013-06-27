class MezuroPlugin::Helpers::ModuleResultHelper

  def self.module_name name
    name.is_a?(Array) ? name.last : name
  end

end
