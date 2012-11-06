require "test_helper"

require "#{RAILS_ROOT}/plugins/mezuro/test/fixtures/project_fixtures"

class ProjectTest < ActiveSupport::TestCase

  def setup
    @hash = ProjectFixtures.project_hash
    @project = ProjectFixtures.project
    @created_project = ProjectFixtures.created_project
    @project_content = ProjectFixtures.project_content
  end
  
  should 'initialize new project from hash' do
    project = Kalibro::Project.new @hash
    assert_equal @hash[:name], project.name
  end

  should 'convert project to hash' do
    hash = @project.to_hash
    assert_equal @project.name, hash[:name]
  end

  should 'answer if project exists in kalibro' do
    Kalibro::Project.expects(:request).with("Project", :project_exists, {:project_id => @project.id}).returns({:exists => true})
    assert Kalibro::Project.exists?(@project.id)
  end

  should 'find project' do
    Kalibro::Project.expects(:request).with("Project", :get_project, {:project_id => @project.id}).returns(:project => @hash)
    assert_equal @hash[:name], Kalibro::Project.find(@project.id).name
  end

  should 'raise error when project doesnt exist' do
    request_body = {:project_id => @project.id}
    Kalibro::Project.expects(:request).with("Project", :get_project, request_body).raises(Exception.new("(S:Server) There is no project with id #{@project.id}"))
    assert_raise Exception do Kalibro::Project.find(@project.id) end
  end

  should 'get project of a repository' do
    repository_id = 31
    Kalibro::Project.expects(:request).with("Project", :project_of, {:repository_id => repository_id}).returns({:project => @hash})
    assert_equal @hash[:name], Kalibro::Project.project_of(repository_id).name
  end

  should 'get all project' do
    Kalibro::Project.expects(:request).with("Project", :all_projects).returns({:project => [@hash]})
    assert_equal @hash[:name], Kalibro::Project.all.first.name
  end

  should 'return empty when there are no projects' do
    Kalibro::Project.expects(:request).with("Project", :all_projects).returns({:project => nil})
    assert_equal [], Kalibro::Project.all
  end

  should 'return true when project is saved successfully' do
    id_from_kalibro = 1
    Kalibro::Project.expects(:request).with("Project", :save_project, {:project => @created_project.to_hash}).returns(id_from_kalibro)
    assert @created_project.save
    assert_equal id_from_kalibro, @created_project.id
  end

  should 'return false when project is not saved successfully' do
    Kalibro::Project.expects(:request).with("Project", :save_project, {:project => @project.to_hash}).raises(Exception.new)
    assert !(@project.save)
    assert_nil @created_project.id
  end

  should 'remove existent project from service' do
    Kalibro::Project.expects(:request).with("Project", :delete_project, {:project_id => @project.id})
    @project.destroy
  end

=begin  
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
=end

end
