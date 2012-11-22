require "test_helper"

require "#{RAILS_ROOT}/plugins/mezuro/test/fixtures/project_fixtures"
require "#{RAILS_ROOT}/plugins/mezuro/test/fixtures/project_content_fixtures"
require "#{RAILS_ROOT}/plugins/mezuro/test/fixtures/processing_fixtures"
require "#{RAILS_ROOT}/plugins/mezuro/test/fixtures/module_fixtures"
require "#{RAILS_ROOT}/plugins/mezuro/test/fixtures/module_result_fixtures"
require "#{RAILS_ROOT}/plugins/mezuro/test/fixtures/date_metric_result_fixtures"

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
  
  should 'get processing of a repository' do
    Kalibro::Processing.expects(:has_ready_processing).with(@repository.id).returns(true)
    Kalibro::Processing.expects(:last_ready_processing_of).with(@repository.id).returns(@processing)
    assert_equal @processing, @project_content.processing(@repository.id)
  end
  
  should 'get not ready processing of a repository' do
    Kalibro::Processing.expects(:has_ready_processing).with(@repository.id).returns(false)
    Kalibro::Processing.expects(:last_processing_of).with(@repository.id).returns(@processing)
    assert_equal @processing, @project_content.processing(@repository.id)
  end
  
  should 'get processing of a repository after date' do
    Kalibro::Processing.expects(:has_processing_after).with(@repository.id, @date).returns(true)
    Kalibro::Processing.expects(:first_processing_after).with(@repository.id, @date).returns(@processing)
    assert_equal @processing, @project_content.processing_with_date(@repository.id, @date)
  end
  
  should 'get processing of a repository before date' do
    Kalibro::Processing.expects(:has_processing_after).with(@repository.id, @date).returns(false)
    Kalibro::Processing.expects(:has_processing_before).with(@repository.id, @date).returns(true)
    Kalibro::Processing.expects(:last_processing_before).with(@repository.id, @date).returns(@processing)
    assert_equal @processing, @project_content.processing_with_date(@repository.id, @date)
  end

  should 'get module result' do
    @project_content.expects(:processing).with(@repository.id).returns(@processing)
    Kalibro::ModuleResult.expects(:find).with(@processing.results_root_id).returns(@module_result)
    assert_equal @module_result, @project_content.module_result(@repository.id)

  end
  
  should 'get module result with date' do
    @project_content.expects(:processing_with_date).with(@repository.id,@date.to_s).returns(@processing)
    Kalibro::ModuleResult.expects(:find).with(@processing.results_root_id).returns(@module_result)
    assert_equal @module_result, @project_content.module_result(@repository.id, @date.to_s)
  end

  should 'get result history' do
    Kalibro::MetricResult.expects(:history_of).with(@module_result.id).returns([@date_metric_result])
    assert_equal [@date_metric_result], @project_content.result_history(@module_result.id)
  end

  should 'add error to base when the module_result does not exist' do
    Kalibro::MetricResult.expects(:history_of).with(@module_result.id).raises(Kalibro::Errors::RecordNotFound)
    assert_nil @project_content.errors[:base]
    @project_content.result_history(@module_result.id)
    assert_not_nil @project_content.errors[:base]
  end

end
