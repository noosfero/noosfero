require 'test_helper'

require "#{RAILS_ROOT}/plugins/mezuro/test/fixtures/reading_fixtures"
require "#{RAILS_ROOT}/plugins/mezuro/test/fixtures/reading_group_content_fixtures"

class MezuroPluginReadingControllerTest < ActionController::TestCase

  def setup
    @controller = MezuroPluginReadingController.new
    @request = ActionController::TestRequest.new
    @response = ActionController::TestResponse.new
    @profile = fast_create(Profile)

    @reading = ReadingFixtures.reading
    @created_reading = ReadingFixtures.created_reading
    @reading_hash = ReadingFixtures.hash
    @content = MezuroPlugin::ReadingGroupContent.new(:profile => @profile, :name => name)
    @content.expects(:send_reading_group_to_service).returns(nil)
    @content.stubs(:solr_save)
    @content.save
  end

  should 'set variables to create a new reading' do
    parser = "|*|"    
    Kalibro::Reading.expects(:readings_of).with(@content.reading_group_id).returns([@reading])
    get :new, :profile => @profile.identifier, :id => @content.id
    assert_equal parser, assigns(:parser)
    assert_equal ["#{@reading.label}#{parser}#{@reading.grade}#{parser}"], assigns(:labels_and_grades)
    assert_equal @content.id, assigns(:reading_group_content).id
    assert_response :success
  end

  should 'create a reading' do
    Kalibro::Reading.expects(:new).with(@reading_hash.to_s).returns(@created_reading)
    @created_reading.expects(:save).with(@content.reading_group_id).returns(true)
    get :save, :profile => @profile.identifier, :id => @content.id, :reading => @reading_hash
    assert @created_reading.errors.empty?
    assert_response :redirect
  end

  should 'put an Exception in reading when an error occurs in create action' do
    @created_reading.errors = [Exception.new]
    Kalibro::Reading.expects(:new).with(@reading_hash.to_s).returns(@created_reading)
    @created_reading.expects(:save).with(@content.reading_group_id).returns(false)
    get :save, :profile => @profile.identifier, :id => @content.id, :reading => @reading_hash
    assert !@created_reading.errors.empty?
    assert_response :redirect
  end

  should 'set variables to edit a reading' do
    parser = "|*|"    
    another_reading = ReadingFixtures.reading
    another_reading.id = 10
    Kalibro::Reading.expects(:readings_of).with(@content.reading_group_id).returns([@reading, another_reading])
    Kalibro::Reading.expects(:find).with(@reading.id.to_s).returns(@reading)
    get :edit, :profile => @profile.identifier, :id => @content.id, :reading_id => @reading.id
    assert_equal @content.id, assigns(:reading_group_content).id
    assert_equal @reading, assigns(:reading)
    assert_equal parser, assigns(:parser)
    assert_equal ["#{another_reading.label}#{parser}#{another_reading.grade}#{parser}"], assigns(:labels_and_grades)
    assert_response :success
  end

  should 'destroy a reading' do
    @reading.expects(:destroy)    
    Kalibro::Reading.expects(:find).with(@reading.id.to_s).returns(@reading)

    get :destroy, :profile => @profile.identifier, :id => @content.id, :reading_id => @reading.id

    assert @reading.errors.empty?
    assert_response :redirect
  end

  should 'put an Exception in reading when an error occurs in destroy action' do
    @reading.errors = [Exception.new]
    @reading.expects(:destroy)
    Kalibro::Reading.expects(:find).with(@reading.id.to_s).returns(@reading)

    get :destroy, :profile => @profile.identifier, :id => @content.id, :reading_id => @reading.id

    assert !@reading.errors.empty?
    assert_response :redirect
  end
end
