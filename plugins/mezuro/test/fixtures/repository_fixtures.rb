class RepositoryFixtures

  def self.qt_calculator
    repository = Kalibro::Repository.new
    repository.type = 'SUBVERSION'
    repository.address = 'https://qt-calculator.svn.sourceforge.net/svnroot/qt-calculator'
    repository
  end

  def self.qt_calculator_hash
    {:type => 'SUBVERSION', :address => 'https://qt-calculator.svn.sourceforge.net/svnroot/qt-calculator'}
  end

end
