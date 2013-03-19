class ReadingFixtures

  def self.reading
    Kalibro::Reading.new reading_hash
  end
  
  def self.created_reading # A created object has no id before being sent to kalibro
    Kalibro::Reading.new :label => "Reading Test Label", :grade => "10.5", :color => "AABBCC", :group_id => "31"
  end

  def self.reading_hash
    {:id => "42", :label => "Reading Test Label", :grade => "10.5", :color => "AABBCC", :group_id => "31"}
  end

end

