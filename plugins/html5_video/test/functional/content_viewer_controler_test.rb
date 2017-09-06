require 'test_helper'
require_relative '../download_fixture'
require_relative '../html5_video_plugin_test_helper'

class ContentViewerController
  # Re-raise errors caught by the controller.
  def rescue_action(e) raise e end
  append_view_path File.join(File.dirname(__FILE__) + '/../../views')
end

class ContentViewerControllerTest < ActionController::TestCase

  prepend Html5VideoPluginTestHelper
  all_fixtures

  def setup
    @controller = ContentViewerController.new

    @profile = create_user('testinguser').person
    @environment = @profile.environment
    @environment.enable_plugin(Html5VideoPlugin)
  end
  attr_reader :profile, :environment

  should 'add html5 video tag to the page of file type video' do
    video = create_video('atropelamento.ogv', 'video/ogg', profile)
    process_file(video)

    get :view_page, video.url.merge(:view=>:true)
    assert_select '#article video'
  end

end
