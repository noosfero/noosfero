require "test_helper"

require "#{RAILS_ROOT}/plugins/mezuro/test/fixtures/repository_fixtures"

class RepositoryTest < ActiveSupport::TestCase

  def setup
    @hash = RepositoryFixtures.repository_hash
    @repository = RepositoryFixtures.repository
  end

  should 'new repository from hash' do
    assert_equal @repository.type, Kalibro::Repository.new(@hash).type
  end

  should 'convert repository to hash' do
    assert_equal @hash, @repository.to_hash
  end

  should 'get supported repository types' do
    types = ['BAZAAR', 'GIT', 'SUBVERSION']
    Kalibro::Repository.expects(:request).with('Kalibro', :get_supported_repository_types).returns({:repository_type => types})
    assert_equal types, Kalibro::Repository.repository_types
  end

end
