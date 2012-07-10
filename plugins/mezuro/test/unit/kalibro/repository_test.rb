require "test_helper"

require "#{RAILS_ROOT}/plugins/mezuro/test/fixtures/repository_fixtures"

class RepositoryTest < ActiveSupport::TestCase

  def setup
    @hash = RepositoryFixtures.qt_calculator_hash
    @repository = RepositoryFixtures.qt_calculator
  end

  #TODO como pegar o nome de TODAS as variáveis, mesmo as não setadas???
  should 'create repository from hash' do
    repository = Kalibro::Repository.new(@hash)
    attributes = repository.instance_variable_names.map { |variable| variable.to_s.sub(/@/, '') }
    attributes.each { |field| assert_equal(@repository.send("#{field}"), repository.send("#{field}")) }
    attributes = @repository.instance_variable_names.map { |variable| variable.to_s.sub(/@/, '') }
    attributes.each { |field| assert_equal(@repository.send("#{field}"), repository.send("#{field}")) }
  end

  should 'convert repository to hash' do
    assert_equal @hash, @repository.to_hash
  end

end
