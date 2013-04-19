class ProcessTimeFixtures

  def self.process_time
    Kalibro::ProcessTime.new process_time_hash
  end

  def self.process_time_hash
    {:state => "Ready", :time => "1"}
  end

end
