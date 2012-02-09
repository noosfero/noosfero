require "test_helper"

require "#{RAILS_ROOT}/plugins/mezuro/test/fixtures/project_fixtures"

class ProjectTest < ActiveSupport::TestCase

  def setup
    @hash = ProjectFixtures.qt_calculator_hash
    @project = ProjectFixtures.qt_calculator
  end

  should 'create project from hash' do
    assert_equal @project, Kalibro::Entities::Project.from_hash(@hash)
  end

  should 'convert project to hash' do
    assert_equal @hash, @project.to_hash
  end
  
end