class ProjectClientTest < Test::Unit::TestCase

  def setup
    @port = mock
    Kalibro::Client::Port.expects(:new).with('Project').returns(@port)
    @client = Kalibro::Client::ProjectClient.new
  end

  should 'save project' do
    project = ProjectTest.qt_calculator
    @port.expects(:request).with(:save_project, {:project => project.to_hash})
    @client.save(project)
  end

  should 'get project names (zero)' do
    @port.expects(:request).with(:get_project_names).returns({})
    assert_equal [], @client.project_names
  end

  should 'get project names (one)' do
    name = 'Qt-Calculator'
    @port.expects(:request).with(:get_project_names).returns({:project_name => name})
    assert_equal [name], @client.project_names
  end

  should 'get project names' do
    names = ['Hello World', 'Qt-Calculator']
    @port.expects(:request).with(:get_project_names).returns({:project_name => names})
    assert_equal names, @client.project_names
  end

  should 'get project by name' do
    project = ProjectTest.qt_calculator
    request_body = {:project_name => project.name}
    response_hash = {:project => project.to_hash}
    @port.expects(:request).with(:get_project, request_body).returns(response_hash)
    assert_equal project, @client.project(project.name)
  end

  should 'remove project by name' do
    name = 'ProjectClientTest'
    @port.expects(:request).with(:remove_project, {:project_name => name})
    @client.remove(name)
  end

end