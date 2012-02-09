require "test_helper"

require "#{RAILS_ROOT}/plugins/mezuro/test/fixtures/repository_fixtures"

class RepositoryTest < ActiveSupport::TestCase

  def setup
    @hash = RepositoryFixtures.qt_calculator_hash
    @repository = RepositoryFixtures.qt_calculator
  end

  should 'create repository from hash' do
    assert_equal @repository, Kalibro::Entities::Repository.from_hash(@hash)
  end

  should 'convert repository to hash' do
    assert_equal @hash, @repository.to_hash
  end

end