require 'test_helper'
require 'cms_controller'

# Re-raise errors caught by the controller.
class CmsController; def rescue_action(e) raise e end; end

class CmsControllerTest < ActionController::TestCase

  def setup
    @controller = CmsController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    @person = create_user('test_user').person
    login_as :test_user
  end

  attr_accessor :person

  should 'not allow non-members to upload submissions on work_assignment' do
    organization = fast_create(Organization)
    work_assignment = WorkAssignmentPlugin::WorkAssignment.create!(:name => 'Work Assignment', :profile => organization)

    get :upload_files, :profile => organization.identifier, :parent_id => work_assignment.id
    assert_response :forbidden
    assert_template 'access_denied.rhtml'

    organization.add_member(person)

    get :upload_files, :profile => organization.identifier, :parent_id => work_assignment.id
    assert_response :success
  end

  should 'upload submission and automatically move it to the author folder' do
    organization = fast_create(Organization)
    work_assignment = WorkAssignmentPlugin::WorkAssignment.create!(:name => 'Work Assignment', :profile => organization)
    organization.add_member(person)
    post :upload_files, :profile => organization.identifier, :parent_id => work_assignment.id, :uploaded_files => [fixture_file_upload('/files/test.txt', 'text/plain')]

    submission = UploadedFile.last
    assert_equal work_assignment.find_or_create_author_folder(person), submission.parent
  end

end

