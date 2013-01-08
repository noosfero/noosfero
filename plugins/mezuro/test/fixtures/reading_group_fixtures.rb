class ReadingGroupFixtures

  def self.reading_group
    Kalibro::ReadingGroup.new reading_group_hash
  end

  def self.created_reading_group  # A created object has no id before being sent to kalibro
    Kalibro::ReadingGroup.new :name => "Reading Group Test", :description => "Reading group in the fixtures"
  end

  def self.reading_group_hash
    {:id => "42", :name => "Reading Group Test", :description => "Reading group in the fixtures"}
  end

end
