class ProjectContentTest < Test::Unit::TestCase

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
    project_client = mock
    kalibro_client = mock
    Kalibro::Client::ProjectClient.expects(:new).returns(project_client)
    project_client.expects(:save).with(@project)
    Kalibro::Client::KalibroClient.expects(:new).returns(kalibro_client)
    kalibro_client.expects(:process_project).with(@project.name)
    @content.send :send_project_to_service
  end

end