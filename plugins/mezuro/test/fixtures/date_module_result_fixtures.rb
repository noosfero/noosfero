require File.dirname(__FILE__) + '/module_result_fixtures'

class DateModuleResultFixtures

  def self.date_module_result
    Kalibro::DateModuleResult.new date_module_result_hash
  end

  def self.date_module_result_hash
    {
      :date => '2011-10-20T18:26:43.151+00:00',
      :module_result => ModuleResultFixtures.module_result_hash,
      :attributes! =>
      {
        :module_result =>
        {
          "xmlns:xsi"=>"http://www.w3.org/2001/XMLSchema-instance",
          "xsi:type"=>"kalibro:moduleResultXml"
        }
      }
    }
  end

end
