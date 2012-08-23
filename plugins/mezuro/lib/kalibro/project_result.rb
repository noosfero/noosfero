class Kalibro::ProjectResult < Kalibro::Model

  attr_accessor :project, :date, :load_time, :analysis_time, :source_tree, :collect_time

  def self.last_result(project_name)
    new request('ProjectResult', :get_last_result_of, {:project_name => project_name})[:project_result]
  end
  
  def self.first_result(project_name)
    new request('ProjectResult', :get_first_result_of, {:project_name => project_name})[:project_result]
  end

  def self.first_result_after(project_name, date)
    new request('ProjectResult', :get_first_result_after, {:project_name => project_name, :date => date})[:project_result]
  end

  def self.last_result_before(project_name, date)
    new request('ProjectResult', :get_last_result_before, {:project_name => project_name, :date => date})[:project_result]
  end

  def self.has_results?(project_name)
    request('ProjectResult', :has_results_for, {:project_name => project_name})[:has_results]
  end
  
  def self.has_results_before?(project_name, date)
    request('ProjectResult', :has_results_before, {:project_name => project_name, :date => date})[:has_results]
  end

  def self.has_results_after?(project_name, date)
    request('ProjectResult', :has_results_after, {:project_name => project_name, :date => date})[:has_results]
  end
  
  def project=(value)
    @project = (value.kind_of?(Hash)) ? Kalibro::Project.new(value) : value
  end
  
  def date=(value)
    @date = value.is_a?(String) ? DateTime.parse(value) : value
  end

  def load_time=(value)
    @load_time = value.to_i
  end

  def collect_time=(value)
    @collect_time = value.to_i
  end

  def analysis_time=(value)
    @analysis_time = value.to_i
  end
  
  def source_tree=(value)
    @source_tree = value.kind_of?(Hash) ? Kalibro::ModuleNode.new(value) : value
  end
  
  def formatted_load_time
    format_milliseconds(@load_time)
  end

  def formatted_analysis_time
     format_milliseconds(@analysis_time)
  end

  def format_milliseconds(value)
    seconds = value.to_i/1000
    hours = seconds/3600
    seconds -= hours * 3600
    minutes = seconds/60
    seconds -= minutes * 60
    "#{format(hours)}:#{format(minutes)}:#{format(seconds)}"
  end

  def format(amount)
    ('%2d' % amount).sub(/\s/, '0')
  end
  
  def node(module_name)
    if module_name.nil? or module_name == project.name
      node = source_tree
    else
		path = Kalibro::Module.parent_names(module_name)
		parent = @source_tree
		path.each do |node_name|
		  parent = get_leaf_from(parent, node_name)
		end
		parent
	end
  end
  
  private

  def get_leaf_from(node, module_name) 
    node.children.each do |child_node|
      return child_node if child_node.module.name == module_name
    end
    nil
  end

end
