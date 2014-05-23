require "test_helper"

require "#{Rails.root}/plugins/mezuro/test/fixtures/project_fixtures"
require "#{Rails.root}/plugins/mezuro/test/fixtures/project_content_fixtures"
require "#{Rails.root}/plugins/mezuro/test/fixtures/processing_fixtures"
require "#{Rails.root}/plugins/mezuro/test/fixtures/module_fixtures"
require "#{Rails.root}/plugins/mezuro/test/fixtures/module_result_fixtures"
require "#{Rails.root}/plugins/mezuro/test/fixtures/date_metric_result_fixtures"

class ProjectContentTest < ActiveSupport::TestCase

  def setup
    @project_content = ProjectContentFixtures.project_content
    @project = ProjectFixtures.project
    @repository = RepositoryFixtures.repository
    @processing = ProcessingFixtures.processing
    @date = @processing.date
    @module = ModuleFixtures.module
    @module_result = ModuleResultFixtures.module_result
    @date_metric_result = DateMetricResultFixtures.date_metric_result
  end

  should 'provide proper short description' do
    assert_equal 'Mezuro project', MezuroPlugin::ProjectContent.short_description
  end

  should 'provide proper description' do
    assert_equal 'Software project tracked by Kalibro', MezuroPlugin::ProjectContent.description
  end

  should 'have an html view' do
    assert_not_nil @project_content.to_html
  end

  should 'get project from service' do
    Kalibro::Project.expects(:find).with(@project.id).returns(@project)
    assert_equal @project, @project_content.project
  end

  should 'add error to base when the project does not exist' do
    Kalibro::Project.expects(:find).with(@project.id).raises(Kalibro::Errors::RecordNotFound)
    assert_nil @project_content.errors[:base]
    @project_content.project
    assert_not_nil @project_content.errors[:base]
  end

  should 'get repositories of the project from service' do
    Kalibro::Repository.expects(:repositories_of).with(@project.id).returns([@repository])
    assert_equal [@repository], @project_content.repositories
  end
  
  should 'add error to base when getting the repositories of a project that does not exist' do
    Kalibro::Repository.expects(:repositories_of).with(@project.id).raises(Kalibro::Errors::RecordNotFound)
    assert_nil @project_content.errors[:base]
    @project_content.repositories
    assert_not_nil @project_content.errors[:base]
  end

end
