require File.dirname(__FILE__) + '/module_fixtures'

class ModuleResultFixtures

  def self.module_result
    Kalibro::ModuleResult.new module_result_hash
  end

  def self.module_result_hash
    {
      :id => "42",
      :module => ModuleFixtures.module_hash,
      :grade => "10.0",
      :parent_id => "31",
      :attributes! =>
      {
        :module =>
        {
          "xmlns:xsi"=>"http://www.w3.org/2001/XMLSchema-instance",
          "xsi:type"=>"kalibro:moduleXml"
        }
      }
    }
  end

  def self.parent_module_result_hash
    {
      :id => "31",
      :module =>  {
        :name => 'Qt-Calculator Parent',
        :granularity => 'APPLICATION'
      },
      :grade => "10.0",
      :attributes! =>
      {
        :module =>
        {
          "xmlns:xsi"=>"http://www.w3.org/2001/XMLSchema-instance",
          "xsi:type"=>"kalibro:moduleXml"
        }
      }
    }
  end
end
