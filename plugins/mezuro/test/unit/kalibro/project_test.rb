require "test_helper"

require "#{RAILS_ROOT}/plugins/mezuro/test/fixtures/project_fixtures"

class ProjectTest < ActiveSupport::TestCase

  def setup
    @hash = ProjectFixtures.qt_calculator_hash
    @project = ProjectFixtures.qt_calculator
  end

  should 'get project by name' do
    request_body = {:project_name => @project.name}
    response_hash = {:project => @hash}
    Kalibro::Project.expects(:request).with(:get_project, request_body).returns(response_hash)
    assert_equal @project, Kalibro::Project.find_by_name(@project.name)
  end

=begin 
  should 'raise error when project doesnt exist' do
    request_body = {:project_name => @project.name}
    @port.expects(:request).with(:get_project, request_body).raises(Exception.new("(S:Server) There is no project named " + @project.name))
    assert_nil Kalibro::Client::ProjectClient.project(@project.name)
  end

  should 'save project' do
    create_project_content_mock
    @project.state = nil
    @port.expects(:request).with(:save_project, {:project => @project.to_hash})
    Kalibro::Client::ProjectClient.save(@project_content)
  end

  should 'remove existent project from service' do
    @port.expects(:request).with(:get_project_names).returns({:project_name => @project.name})
    @port.expects(:request).with(:remove_project, {:project_name => @project.name})
    Kalibro::Client::ProjectClient.remove(@project.name)
  end

  should 'not try to remove inexistent project from service' do
    @port.expects(:request).with(:get_project_names).returns({:project_name => 'Different project'})
    @port.expects(:request).with(:remove_project, {:project_name => @project.name}).never
    Kalibro::Client::ProjectClient.remove(@project.name)
  end

  private

  def create_project_content_mock
    @project_content = mock
    @project_content.expects(:name).returns(@project.name)
    @project_content.expects(:license).returns(@project.license)
    @project_content.expects(:description).returns(@project.description)
    @project_content.expects(:repository_type).returns(@project.repository.type)
    @project_content.expects(:repository_url).returns(@project.repository.address)
    @project_content.expects(:configuration_name).returns(@project.configuration_name)
  end

  should 'create project from hash' do
    assert_equal @project, Kalibro::Project.new(@hash)
  end

  should 'convert project to hash' do
    assert_equal @hash, @project.to_hash
  end
=end  
end
