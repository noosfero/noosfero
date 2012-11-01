class ReadingGroupFixtures

  def self.reading_group
    Kalibro::ReadingGroup.new reading_group_hash
  end

  def self.reading_group_hash
    {:id => 42, :name => "Reading Group Test", :description => "Reading group in the fixtures"}
  end

end
