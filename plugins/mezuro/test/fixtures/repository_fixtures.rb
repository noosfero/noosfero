class RepositoryFixtures

  def self.repository
    Kalibro::Repository.new repository_hash
  end

  def self.created_repository
    Kalibro::Repository.new({
      :name => "test created repository",
      :description => "test description",
      :license => "GPL",
      :process_period => "1",
      :type => 'SUBVERSION',
      :address => 'https://qt-calculator.svn.sourceforge.net/svnroot/qt-calculator',
      :configuration_id => "31",
      :project_id => "32"
    })
  end

  def self.repository_hash
    {:id => "42", :name => "test repository", :description => "test description", :license => "GPL", :process_period => "1", :type => 'SUBVERSION', :address => "https://qt-calculator.svn.sourceforge.net/svnroot/qt-calculator", :configuration_id => "31", :project_id => "32"}
  end

  def self.types
    ["SUBVERSION", "GIT"]
  end

end
