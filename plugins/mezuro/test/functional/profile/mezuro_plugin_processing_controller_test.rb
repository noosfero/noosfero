require 'test_helper' 

require "#{RAILS_ROOT}/plugins/mezuro/test/fixtures/processing_fixtures"
require "#{RAILS_ROOT}/plugins/mezuro/test/fixtures/throwable_fixtures"
require "#{RAILS_ROOT}/plugins/mezuro/test/fixtures/repository_fixtures"


class MezuroPluginProcessingControllerTest < ActionController::TestCase
  def setup
    @controller = MezuroPluginProcessingController.new
    @request = ActionController::TestRequest.new
    @response = ActionController::TestResponse.new
    @profile = fast_create(Community)

    @repository_id = RepositoryFixtures.repository.id
    @processing = ProcessingFixtures.processing
    @processing_hash = ProcessingFixtures.processing_hash
    @processing_with_error_hash = ProcessingFixtures.processing_with_error_hash
  end

  should 'render last processing state' do
    Kalibro::Processing.expects(:processing_of).with(@repository_id).returns(@processing)
    get :state, :profile => @profile.identifier, :repository_id => @repository_id
    assert_response :success
    assert_equal @processing.state, @response.body
  end

  should 'render a processing state in a specific date' do
    Kalibro::Processing.expects(:processing_with_date_of).with(@repository_id, @processing.date).returns(@processing)
    get :state, :profile => @profile.identifier, :repository_id => @repository_id, :date => @processing.date
    assert_response :success
    assert_equal @processing.state, @response.body
  end

  should 'render processing with error' do
    Kalibro::Processing.expects(:request).with(:has_ready_processing, {:repository_id => @repository_id}).returns({:exists => false})
    Kalibro::Processing.expects(:request).with(:last_processing, :repository_id => @repository_id).returns({:processing => @processing_with_error_hash})
    get :processing, :profile => @profile.identifier, :repository_id => @repository_id
    assert_response :success
    assert_equal @processing_with_error_hash[:state], assigns(:processing).state
    #TODO How to assert from view? assert_select('h3', 'ERROR')
  end

  should 'test project result without date' do
    Kalibro::Processing.expects(:request).with(:has_ready_processing, {:repository_id => @repository_id}).returns({:exists => true})
    Kalibro::Processing.expects(:request).with(:last_ready_processing, {:repository_id => @repository_id}).returns({:processing => @processing_hash})
    get :processing, :profile => @profile.identifier, :repository_id => @repository_id
    assert_response :success
    assert_select('h4', 'Last Result')
  end
  
  should 'test project results from a specific date' do
    Kalibro::Processing.expects(:request).with(:has_processing_after, {:repository_id => @repository_id, :date => @processing.date}).returns({:exists => true})
    Kalibro::Processing.expects(:request).with(:first_processing_after, :repository_id => @repository_id, :date => @processing.date).returns({:processing => @processing_hash})
    get :processing, :profile => @profile.identifier, :repository_id => @repository_id, :date => @processing.date
    assert_response :success
    assert_select('h4', 'Last Result')
  end

end
