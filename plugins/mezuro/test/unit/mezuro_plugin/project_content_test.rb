require "test_helper"
class ProjectContentTest < ActiveSupport::TestCase

  def setup
    @project = ProjectTest.qt_calculator
    @content = MezuroPlugin::ProjectContent.new
    @content.name = @project.name
    @content.license = @project.license
    @content.description = @project.description
    @content.repository_type = @project.repository.type
    @content.repository_url = @project.repository.address
    @content.configuration_name = @project.configuration_name
  end

  should 'be an article' do
    assert_kind_of Article, @content
  end

  should 'provide proper short description' do
    assert_equal 'Kalibro project', MezuroPlugin::ProjectContent.short_description
  end

  should 'provide proper description' do
    assert_equal 'Software project tracked by Kalibro', MezuroPlugin::ProjectContent.description
  end

  should 'have an html view' do
    assert_not_nil @content.to_html
  end

  should 'run send project to service on after_save callback' do
    @content.expects :send_project_to_service
    @content.run_callbacks :after_save
  end

  should 'send correct project to service' do
    Kalibro::Client::ProjectClient.expects(:save).with(@project)
    Kalibro::Client::KalibroClient.expects(:process_project).with(@project.name)
    @content.send :send_project_to_service
  end

  should 'remove project from service' do
    Kalibro::Client::ProjectClient.expects(:remove).with(@project.name)
    @content.send :remove_project_from_service
  end
end
