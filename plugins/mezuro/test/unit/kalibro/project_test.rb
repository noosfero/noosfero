require "test_helper"

require "#{RAILS_ROOT}/plugins/mezuro/test/fixtures/project_fixtures"

class ProjectTest < ActiveSupport::TestCase

  def setup
    @hash = ProjectFixtures.project_hash
    @project = ProjectFixtures.project
    @project_content = ProjectFixtures.project_content
  end

  should 'get all project names' do
    response_hash = {:project_name => [@project.name]}
    Kalibro::Project.expects(:request).with("Project", :get_project_names).returns(response_hash)
    assert_equal response_hash[:project_name], Kalibro::Project.all_names
  end

  should 'find project by name' do
    request_body = {:project_name => @project.name}
    response_hash = {:project => @hash}
    Kalibro::Project.expects(:new).with(@hash).returns(@project)
    Kalibro::Project.expects(:request).with("Project", :get_project, request_body).returns(response_hash)
    assert_equal @project, Kalibro::Project.find_by_name(@project.name)
  end

  should 'raise error when project doesnt exist' do
    request_body = {:project_name => @project.name}
    Kalibro::Project.expects(:request).with("Project", :get_project, request_body).raises(Exception.new("(S:Server) There is no project named " + @project.name))
    assert_raise Exception do Kalibro::Project.find_by_name(@project.name) end
  end

  should 'return true when project is saved successfully' do
    Kalibro::Project.expects(:request).with("Project", :save_project, {:project => @project.to_hash})
    assert @project.save
  end

  should 'return false when project is not saved successfully' do
    Kalibro::Project.expects(:request).with("Project", :save_project, {:project => @project.to_hash}).raises(Exception.new)
    assert !(@project.save)
  end

  should 'remove existent project from service' do
    Kalibro::Project.expects(:request).with("Project", :remove_project, {:project_name => @project.name})
    @project.destroy
  end
  
  should 'initialize new project from hash' do
    project = Kalibro::Project.new @hash
    assert_equal @project.name, project.name
    assert_equal @project.repository.type, project.repository.type
  end

  should 'convert project to hash' do
    hash = @project.to_hash
    assert_equal @hash[:name], hash[:name]
    assert_equal @hash[:configuration_name], hash[:configuration_name]
    assert_equal @hash[:repository], hash[:repository]
    assert_equal @hash[:state], hash[:state]
  end
  
  should 'process project without days' do
    Kalibro::Project.expects(:request).with('Kalibro', :process_project, {:project_name => @project.name})
    @project.process_project
  end

  should 'process project with days' do
    Kalibro::Project.expects(:request).with('Kalibro', :process_periodically, {:project_name => @project.name, :period_in_days => "1"})
    @project.process_project "1"
  end

  should 'process period' do
    Kalibro::Project.expects(:request).with('Kalibro', :get_process_period,  {:project_name => @project.name}).returns({:period => "1"})
    assert_equal "1", @project.process_period
  end
  
  should 'cancel periodic process' do
    Kalibro::Project.expects(:request).with("Kalibro", :cancel_periodic_process, {:project_name => @project.name})
    @project.cancel_periodic_process
  end

end
