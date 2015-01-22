require File.expand_path(File.dirname(__FILE__) + "/../../../../test/test_helper")
require 'content_viewer_controller'

# Re-raise errors caught by the controller.
class ContentViewerController; def rescue_action(e) raise e end; end

class ContentViewerControllerTest < ActionController::TestCase

  def setup
    @controller = ContentViewerController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    @profile = create_user('testinguser').person

    @organization = fast_create(Organization)
    @work_assignment = WorkAssignmentPlugin::WorkAssignment.create!(:name => 'Work Assignment', :profile => @organization)
    @person = create_user('test_user').person
    @organization.add_member(@person)
    @environment = @organization.environment
    @environment.enable_plugin(WorkAssignmentPlugin)
    @environment.save!
    login_as(:test_user)
  end
  attr_reader :organization, :person, :profile, :work_assignment

  should 'can download work_assignment' do
    folder = work_assignment.find_or_create_author_folder(@person)
    submission = UploadedFile.create!(:uploaded_data => fixture_file_upload('/files/rails.png', 'image/png'), :profile => organization, :parent => folder)
    WorkAssignmentPlugin.stubs(:can_download_submission?).returns(false)

    get :view_page, :profile => @organization.identifier, :page => submission.path
    assert_response :forbidden
    assert_template 'access_denied'

    WorkAssignmentPlugin.stubs(:can_download_submission?).returns(true)

    get :view_page, :profile => @organization.identifier, :page => submission.path
    assert_response :success
  end

  should "display 'Upload files' when create children of image gallery" do
    login_as(profile.identifier)
    f = Gallery.create!(:name => 'gallery', :profile => profile)
    xhr :get, :view_page, :profile => profile.identifier, :page => f.explode_path, :toolbar => true
    assert_tag :tag => 'a', :content => 'Upload files', :attributes => {:href => /parent_id=#{f.id}/}
  end

end
