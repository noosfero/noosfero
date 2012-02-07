require "test_helper"
class ProjectTest < ActiveSupport::TestCase

  def self.qt_calculator
    project = Kalibro::Entities::Project.new
    project.name = 'Qt-Calculator'
    project.license = 'GPL'
    project.description = 'Calculator for Qt'
    project.repository = RepositoryTest.qt_calculator
    project.configuration_name = 'Kalibro for Java'
    project.state = 'READY'
    project
  end

  def self.qt_calculator_hash
    {:name => 'Qt-Calculator', :license => 'GPL',
        :description => 'Calculator for Qt',
        :repository => RepositoryTest.qt_calculator_hash,
        :configuration_name => 'Kalibro for Java',
        :state => 'READY'}
  end

  def setup
    @hash = self.class.qt_calculator_hash
    @project = self.class.qt_calculator
  end

  should 'create project from hash' do
    assert_equal @project, Kalibro::Entities::Project.from_hash(@hash)
  end

  should 'convert project to hash' do
    assert_equal @hash, @project.to_hash
  end
  
end