require 'test_helper'
require 'content_viewer_controller'

class ContentViewerControllerTest < ActionController::TestCase

  all_fixtures

  def setup
    @controller = ContentViewerController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new

    @profile = create_user('testinguser').person
    @environment = @profile.environment
  end
  attr_reader :profile, :environment

  should 'add html5 video tag to the page of file type video' do
    file = UploadedFile.create!(:uploaded_data => fixture_file_upload('/files/test.txt', 'video/ogg'), :profile => profile)
    get :view_page, file.url.merge(:view=>:true)
    assert_select '#article video'
  end

end
