require File.dirname(__FILE__) + '/process_time_fixtures'

class ProcessingFixtures

  def self.processing
    Kalibro::Processing.new processing_hash  
  end

  def self.processing_hash
    {
      :id => 31,
      :date => '2011-10-20T18:26:43.151+00:00',
      :state => 'READY',
      :process_times => [ProcessTimeFixtures.process_time_hash],
      :results_root_id => 13  
    }
  end
    
end
