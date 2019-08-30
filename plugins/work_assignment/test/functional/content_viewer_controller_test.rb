require "test_helper"

class ContentViewerControllerTest < ActionController::TestCase
  def setup
    @controller = ContentViewerController.new

    @profile = create_user("testinguser").person

    @organization = fast_create(Organization)
    @work_assignment = WorkAssignmentPlugin::WorkAssignment.create!(name: "Work Assignment",
                                                                    profile: @organization)
    @person = create_user("test_user").person
    @organization.add_member(@person)
    @environment = @organization.environment
    @environment.enable_plugin(WorkAssignmentPlugin)
    @environment.save!
    login_as(:test_user)
  end
  attr_reader :organization, :person, :profile, :work_assignment

  # TODO: The work_assignment plugin is using the published variable in a way
  # that is breaking the new Accesslevel implementation.
  # should 'can download work_assignment' do
  #  folder = work_assignment.find_or_create_author_folder(@person)
  #  submission = UploadedFile.create!(:uploaded_data => fixture_file_upload('/files/rails.png', 'image/png'),
  #                                    :profile => organization, :parent => folder)

  #  WorkAssignmentPlugin.stubs(:can_download_submission?).returns(false)

  #  get :view_page, :profile => @organization.identifier, :page => submission.path
  #  assert_response :forbidden
  #  assert_template 'shared/access_denied'

  #  WorkAssignmentPlugin.stubs(:can_download_submission?).returns(true)

  #  get :view_page, :profile => @organization.identifier, :page => submission.path
  #  assert_response :success
  # end

  should "display users submissions" do
    folder = work_assignment.find_or_create_author_folder(@person)
    submission = UploadedFile.create!(uploaded_data: fixture_file_upload("/files/rails.png", "image/png"), profile: organization, parent: folder)
    get :view_page, profile: @organization.identifier, page: work_assignment.path
    assert_response :success
    assert_match /rails/, @response.body
  end

  should "display 'Upload files' when create children of image gallery" do
    login_as(profile.identifier)
    f = Gallery.create!(name: "gallery", profile: profile)
    get :view_page, xhr: true, params: { profile: profile.identifier, page: f.explode_path, toolbar: true }
    assert_tag tag: "a", content: "Upload files", attributes: { href: /parent_id=#{f.id}/ }
  end
end
