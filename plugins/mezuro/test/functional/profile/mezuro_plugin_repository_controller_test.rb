require 'test_helper'

require "#{RAILS_ROOT}/plugins/mezuro/test/fixtures/processing_fixtures"
require "#{RAILS_ROOT}/plugins/mezuro/test/fixtures/throwable_fixtures"
require "#{RAILS_ROOT}/plugins/mezuro/test/fixtures/repository_fixtures"
require "#{RAILS_ROOT}/plugins/mezuro/test/fixtures/project_content_fixtures"
require "#{RAILS_ROOT}/plugins/mezuro/test/fixtures/configuration_fixtures"

class MezuroPluginRepositoryControllerTest < ActionController::TestCase

  def setup
    @controller = MezuroPluginRepositoryController.new
    @request = ActionController::TestRequest.new
    @response = ActionController::TestResponse.new
    @profile = fast_create(Community)

    @configuration = ConfigurationFixtures.configuration
    @repository_types = RepositoryFixtures.types
    @all_configurations = ConfigurationFixtures.all
    @repository = RepositoryFixtures.repository
    @repository_hash = RepositoryFixtures.hash
    @content = MezuroPlugin::ProjectContent.new(:profile => @profile, :name => name)
    @content.expects(:send_project_to_service).returns(nil)
    @content.stubs(:solr_save)
    @content.save
  end

  should 'set variables to create a new repository' do
    Kalibro::Repository.expects(:repository_types).returns(@repository_types)
    Kalibro::Configuration.expects(:all).returns(@all_configurations)

    get :new, :profile => @profile.identifier, :id => @content.id

    assert_equal @content.id, assigns(:project_content_id)
    assert_equal @content.name, assigns(:project_name)
    assert_equal @repository_types, assigns(:repository_types)
    assert_equal @content.profile.identifier, assigns(:data_profile)
    assert_equal @all_configurations.first.name, assigns(:configuration_select).first.first
    assert_equal @all_configurations.first.id, assigns(:configuration_select).first.last
  end

  should 'create a repository' do
    Kalibro::Repository.expects(:new).returns(@repository)
    @repository.expects(:save).with(@content.project_id).returns(true)
    @repository.expects(:process)
    get :create, :profile => @profile.identifier, :id => @content.id, :repository => @repository_hash
    assert @repository.errors.empty?
    assert_response :redirect
  end

  should 'not create a repository' do
    @repository.errors = [Exception.new]
    Kalibro::Repository.expects(:new).returns(@repository)
    @repository.expects(:save).with(@content.project_id).returns(false)
    get :create, :profile => @profile.identifier, :id => @content.id, :repository => @repository_hash
    assert !@repository.errors.empty?
    assert_response :redirect
  end

  should 'set variables to edit a repository' do
    articles = mock
    Kalibro::Repository.expects(:repository_types).returns(@repository_types)
    Kalibro::Configuration.expects(:all).returns(@all_configurations)
    Kalibro::Repository.expects(:repositories_of).with(@content.project_id).returns([@repository])

    get :edit, :profile => @profile.identifier, :id => @content.id, :repository_id => @repository.id

    assert_equal @content.id, assigns(:project_content_id)
    assert_equal @content.name, assigns(:project_name)
    assert_equal @repository_types, assigns(:repository_types)
    assert_equal @content.profile.identifier, assigns(:data_profile)
    assert_equal @all_configurations.first.name, assigns(:configuration_select).first.first
    assert_equal @all_configurations.first.id, assigns(:configuration_select).first.last
    assert_equal @repository, assigns(:repository)
  end

  should 'update a repository' do
    Kalibro::Repository.expects(:new).returns(@repository)
    @repository.expects(:save).with(@content.project_id).returns(true)
    Kalibro::Repository.expects(:request).with(:process_repository, {:repository_id => @repository.id})
    get :update, :profile => @profile.identifier, :id => @content.id, :repository => @repository_hash
    assert @repository.errors.empty?
    assert_response :redirect
  end

  should 'not update a repository' do
    @repository.errors = [Exception.new]
    Kalibro::Repository.expects(:new).returns(@repository)
    @repository.expects(:save).with(@content.project_id).returns(false)
    get :update, :profile => @profile.identifier, :id => @content.id, :repository => @repository_hash
    assert !@repository.errors.empty?
    assert_response :redirect
  end

  should 'set variables to show a repository' do
    Kalibro::Repository.expects(:repositories_of).with(@content.project_id).returns([@repository])
    Kalibro::Configuration.expects(:configuration_of).with(@repository.id).returns(@configuration)

    get :show, :profile => @profile.identifier, :id => @content.id, :repository_id => @repository.id

    assert_equal @content.name, assigns(:project_name)
    assert_equal @repository, assigns(:repository)
    assert_equal @configuration.name, assigns(:configuration_name)
    assert_equal @content.profile.identifier, assigns(:data_profile)
    assert_equal @content.id, assigns(:data_content)
    assert_response :success
  end

  should 'destroy a repository' do
    @repository.expects(:destroy)    
    Kalibro::Repository.expects(:repositories_of).with(@content.project_id).returns([@repository])

    get :destroy, :profile => @profile.identifier, :id => @content.id, :repository_id => @repository.id

    assert @repository.errors.empty?
    assert_response :redirect
  end

  should 'not destroy a repository' do
    @repository.errors = [Exception.new]
    @repository.expects(:destroy)    
    Kalibro::Repository.expects(:repositories_of).with(@content.project_id).returns([@repository])

    get :destroy, :profile => @profile.identifier, :id => @content.id, :repository_id => @repository.id

    assert !@repository.errors.empty?
    assert_response :redirect
  end
end
