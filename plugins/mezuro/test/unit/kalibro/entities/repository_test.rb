require "test_helper"
class RepositoryTest < ActiveSupport::TestCase

  def self.qt_calculator
    repository = Kalibro::Entities::Repository.new
    repository.type = 'SUBVERSION'
    repository.address = 'https://qt-calculator.svn.sourceforge.net/svnroot/qt-calculator'
    repository
  end

  def self.qt_calculator_hash
    {:type => 'SUBVERSION',
     :address => 'https://qt-calculator.svn.sourceforge.net/svnroot/qt-calculator'}
  end

  def setup
    @hash = self.class.qt_calculator_hash
    @repository = self.class.qt_calculator
  end

  should 'create repository from hash' do
    assert_equal @repository, Kalibro::Entities::Repository.from_hash(@hash)
  end

  should 'convert repository to hash' do
    assert_equal @hash, @repository.to_hash
  end

end