class ReadingGroupContentFixtures

  def self.reading_group_content
    content = MezuroPlugin::ReadingGroupContent.new
    content.reading_group_id = 42
    content
  end

end
