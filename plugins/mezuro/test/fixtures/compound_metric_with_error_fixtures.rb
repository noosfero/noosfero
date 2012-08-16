require File.dirname(__FILE__) + '/error_fixtures'
require File.dirname(__FILE__) + '/compound_metric_fixtures'

class CompoundMetricWithErrorFixtures
    
  def self.compound_metric_with_error
    Kalibro::CompoundMetricWithError.new compound_metric_with_error_hash
  end

  def self.compound_metric_with_error_hash
    {:metric => CompoundMetricFixtures.compound_metric_hash, :error => ErrorFixtures.error_hash,
      :attributes! => {:metric => {
          'xmlns:xsi'=> 'http://www.w3.org/2001/XMLSchema-instance',
          'xsi:type' => 'kalibro:compoundMetricXml'  },
          :error => {
          'xmlns:xsi'=> 'http://www.w3.org/2001/XMLSchema-instance',
          'xsi:type' => 'kalibro:errorXml'  }}}
  end

end
