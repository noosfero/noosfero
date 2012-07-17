require File.dirname(__FILE__) + '/project_fixtures'
require File.dirname(__FILE__) + '/module_node_fixtures'
require File.dirname(__FILE__) + '/module_result_fixtures'

class ProjectResultFixtures

  def self.project_result
    Kalibro::ProjectResult.new project_result_hash  
  end

  def self.project_result_hash
    {
      :project => ProjectFixtures.project_hash,
      :date => ModuleResultFixtures.module_result_hash[:date],
      :load_time => 14878,
      :analysis_time => 1022,
      :source_tree => ModuleNodeFixtures.module_node_hash, 
      :collect_time => 14878,
      :attributes! =>
      {
        :source_tree =>
        {
          "xmlns:xsi"=>"http://www.w3.org/2001/XMLSchema-instance",
          "xsi:type"=>"kalibro:moduleNodeXml"
        },
        :project =>
        {
          "xmlns:xsi"=>"http://www.w3.org/2001/XMLSchema-instance",
          "xsi:type"=>"kalibro:projectXml"
        }
      }
    }
  end
    
end
