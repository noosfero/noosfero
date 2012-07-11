class RepositoryFixtures

  def self.repository
    Kalibro::Repository.new repository_hash
  end

  def self.repository_hash
    {:type => 'SUBVERSION', :address => 'https://qt-calculator.svn.sourceforge.net/svnroot/qt-calculator'}
  end

end
