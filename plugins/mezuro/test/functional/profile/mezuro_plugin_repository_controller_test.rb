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

    @repository = RepositoryFixtures.repository
    @content = MezuroPlugin::ProjectContent.new(:profile => @profile, :name => name)
    @content.expects(:send_project_to_service).returns(nil)
    @content.stubs(:solr_save)
    @content.save
  end

  should 'test stuff' do
    Kalibro::Repository.expects(:repository_types).returns(RepositoryFixtures.types)
    #Kalibro::Configuration.any_instance.expects(:all).returns(ConfigurationFixtures.all)

    get :new_repository, :profile => @profile.identifier, :id => @content.id

    #assert_equal RepositoryFixtures.types, assigns(:repository_types)
  end
end