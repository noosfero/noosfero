require "test_helper"

require "#{RAILS_ROOT}/plugins/mezuro/test/fixtures/project_fixtures"

class ProjectTest < ActiveSupport::TestCase

  def setup
    @hash = ProjectFixtures.project_hash
    @project = ProjectFixtures.project
    @created_project = ProjectFixtures.created_project
  end
  
  should 'initialize new project from hash' do
    project = Kalibro::Project.new @hash
    assert_equal @hash[:name], project.name
    assert_equal @hash[:id].to_i, project.id
  end

  should 'convert project to hash' do
    hash = @project.to_hash
    assert_equal @project.name, hash[:name]
  end

  should 'answer if project exists in kalibro' do
    Kalibro::Project.expects(:request).with(:project_exists, {:project_id => @project.id}).returns({:exists => true})
    assert Kalibro::Project.exists?(@project.id)
  end

  should 'find project' do
    Kalibro::Project.expects(:request).with(:project_exists, {:project_id => @project.id}).returns({:exists => true})
    Kalibro::Project.expects(:request).with(:get_project, {:project_id => @project.id}).returns(:project => @hash)
    assert_equal @hash[:name], Kalibro::Project.find(@project.id).name
  end

  should 'raise RecordNotFound exception when project doesnt exist' do
    Kalibro::Project.expects(:request).with(:project_exists, {:project_id => @project.id}).returns({:exists => false})
    assert_raise(Kalibro::Errors::RecordNotFound){Kalibro::Project.find(@project.id)}
  end

  should 'get all projects when there is only one project' do
    Kalibro::Project.expects(:request).with(:all_projects).returns({:project => @hash})
    assert_equal @hash[:name], Kalibro::Project.all.first.name
  end

  should 'get all projects when there are many projects' do
    Kalibro::Project.expects(:request).with(:all_projects).returns({:project => [@hash, @hash]})
    projects = Kalibro::Project.all
    assert_equal @hash[:name], projects.first.name
    assert_equal @hash[:name], projects.last.name
  end

  should 'return empty when there are no projects' do
    Kalibro::Project.expects(:request).with(:all_projects).returns({:project => nil})
    assert_equal [], Kalibro::Project.all
  end

  should 'return true when project is saved successfully' do
    id_from_kalibro = 1
    Kalibro::Project.expects(:request).with(:save_project, {:project => @created_project.to_hash}).returns(:project_id => id_from_kalibro)
    assert @created_project.save
    assert_equal id_from_kalibro, @created_project.id
  end

  should 'return false when project is not saved successfully' do
    Kalibro::Project.expects(:request).with(:save_project, {:project => @created_project.to_hash}).raises(Exception.new)
    assert !(@created_project.save)
    assert_nil @created_project.id
  end

  should 'remove existent project from service' do
    Kalibro::Project.expects(:request).with(:delete_project, {:project_id => @project.id})
    @project.destroy
  end

end
