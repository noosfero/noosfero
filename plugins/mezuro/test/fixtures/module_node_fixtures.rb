require File.dirname(__FILE__) + '/module_fixtures'

class ModuleNodeFixtures

  def self.module_node
    Kalibro::ModuleNode.new module_node_hash
  end

  def self.module_node_hash
    {
      :module => ModuleFixtures.module_hash,:attributes! => {:module => {
          'xmlns:xsi'=> 'http://www.w3.org/2001/XMLSchema-instance',
          'xsi:type' => 'kalibro:moduleXml'  }},
      :child => [{
        :module => {
          :name => 'org',
          :granularity => 'PACKAGE'
        },:attributes! => {:module => {
          'xmlns:xsi'=> 'http://www.w3.org/2001/XMLSchema-instance',
          'xsi:type' => 'kalibro:moduleXml'  }},
        :child => [{
          :module => {
            :name => 'org.Window',
            :granularity => 'CLASS'
          },:attributes! => {:module => {
          'xmlns:xsi'=> 'http://www.w3.org/2001/XMLSchema-instance',
          'xsi:type' => 'kalibro:moduleXml'  }}
        }]
      },{
        :module => {
          :name => 'Dialog',
          :granularity => 'CLASS'
        },:attributes! => {:module => {
          'xmlns:xsi'=> 'http://www.w3.org/2001/XMLSchema-instance',
          'xsi:type' => 'kalibro:moduleXml'  }}
      },{
        :module => {
          :name => 'main',
          :granularity => 'CLASS'
        },:attributes! => {:module => {
          'xmlns:xsi'=> 'http://www.w3.org/2001/XMLSchema-instance',
          'xsi:type' => 'kalibro:moduleXml'  }}
      }]
    }
  end

end
