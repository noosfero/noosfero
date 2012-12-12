class Kalibro::ModuleResult < Kalibro::Model

  attr_accessor :id, :module, :grade, :parent_id
  
  def self.find(id)
    new request(:get_module_result, { :module_result_id => id })[:module_result]
  end

  def children
    hash_array = self.class.request(:children_of, {:module_result_id => self.id})[:module_result].to_a
    hash_array.map { |module_result| self.class.new module_result }
  end
  
  def module=(value)
    @module = Kalibro::Module.to_object value
  end

  def grade=(value)
    @grade = value.to_f
  end

  def self.history_of(module_result_id)
    response = self.request(:history_of_module, {:module_result_id => module_result_id})[:date_module_result]
    response = [] if response.nil?
    response = [response] if response.is_a?(Hash) 
    response.map {|date_module_result| Kalibro::DateModuleResult.new date_module_result}
  end

end
