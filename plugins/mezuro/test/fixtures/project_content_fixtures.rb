class ProjectContentFixtures

  def self.project_content
    content = MezuroPlugin::ProjectContent.new
    content.project_id = 42
    content
  end

end
