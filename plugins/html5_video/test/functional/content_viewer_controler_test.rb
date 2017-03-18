require 'test_helper'

class ContentViewerController
  # Re-raise errors caught by the controller.
  def rescue_action(e) raise e end
  append_view_path File.join(File.dirname(__FILE__) + '/../../views')
end

class ContentViewerControllerTest < ActionController::TestCase

  all_fixtures

  def setup
    @controller = ContentViewerController.new

    @profile = create_user('testinguser').person
    @environment = @profile.environment
    @environment.enable_plugin(Html5VideoPlugin)
  end
  attr_reader :profile, :environment

  should 'add html5 video tag to the page of file type video' do
    file = UploadedFile.create!(:uploaded_data => fixture_file_upload('/files/test.txt', 'video/ogg'), :profile => profile)
    process_delayed_job_queue
    get :view_page, file.url.merge(:view=>:true)
    assert_select '#article video'
  end

end
