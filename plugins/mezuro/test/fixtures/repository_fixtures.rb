class RepositoryFixtures

  def self.qt_calculator
    Kalibro::Repository.new qt_calculator_hash
  end

  def self.qt_calculator_hash
    {:type => 'SUBVERSION', :address => 'https://qt-calculator.svn.sourceforge.net/svnroot/qt-calculator'}
  end

end
