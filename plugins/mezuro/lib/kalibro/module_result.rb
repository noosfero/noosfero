class Kalibro::ModuleResult < Kalibro::Model

  attr_accessor :id, :module, :grade, :parent_id, :height
  
  def self.find(id)
    new request(:get_module_result, { :module_result_id => id })[:module_result]
  end

  def children
    response = self.class.request(:children_of, {:module_result_id => id})[:module_result]
    response = [] if response.nil?
    response = [response] if response.is_a?(Hash) 
    response.map {|module_result| Kalibro::ModuleResult.new module_result}
  end
  
  def parents
    if parent_id.nil?
      []
    else
      parent = self.class.find(parent_id)
      parent.parents << parent
    end
  end

  def id=(value)
    @id = value.to_i
  end

  def module=(value)
    @module = Kalibro::Module.to_object value
  end

  def grade=(value)
    @grade = value.to_f
  end

  def parent_id=(value)
    @parent_id = value.to_i
  end

  def self.history_of(module_result_id)
    response = self.request(:history_of_module, {:module_result_id => module_result_id})[:date_module_result]
    response = [] if response.nil?
    response = [response] if response.is_a?(Hash) 
    response.map {|date_module_result| Kalibro::DateModuleResult.new date_module_result}
  end

end
