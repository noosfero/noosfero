require File.expand_path(File.dirname(__FILE__) + "/../../../../test/test_helper")
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
    e = Environment.default
    e.enabled_plugins = ['WorkAssignmentPlugin']
    e.save!
    @organization = fast_create(Organization) #
  end

  should 'not allow non-members to upload submissions on work_assignment' do
    work_assignment = create_work_assignment('Work Assignment', @organization, nil, nil)
    get :upload_files, :profile => @organization.identifier, :parent_id => work_assignment.id
    assert_response :forbidden
    assert_template 'access_denied'
  end

  should 'allow members to upload submissions on work_assignment' do
    @organization.add_member(@person)
    # then he trys to upload new stuff
    work_assignment = create_work_assignment('Work Assignment', @organization, nil, nil)
    get :upload_files, :profile => @organization.identifier, :parent_id => work_assignment.id
    assert_response :success
  end

  should 'redirect to Work Assignment view page after upload submission' do
    @organization.add_member(@person)
    work_assignment = create_work_assignment('Work Assignment', @organization, nil, nil)
    post :upload_files, :profile => @organization.identifier, :parent_id => work_assignment.id, :uploaded_files => [fixture_file_upload('/files/test.txt', 'text/plain')] , :back_to => @work_assignment.url
    assert_redirected_to work_assignment.url
  end

  should 'upload submission and automatically move it to the author folder' do
    work_assignment = create_work_assignment('Work Assignment', @organization, nil, nil)
    @organization.add_member(@person)
    post :upload_files, :profile => @organization.identifier, :parent_id => work_assignment.id, :uploaded_files => [fixture_file_upload('/files/test.txt', 'text/plain')]
    submission = UploadedFile.last
    assert_equal work_assignment.find_or_create_author_folder(@person), submission.parent
  end

  should 'work_assignment attribute allow_visibility_edition is true when set a new work_assignment' do
    work_assignment = create_work_assignment('Work Assignment', @organization, nil, true)
    @organization.add_member(@person)
    assert_equal true, work_assignment.allow_visibility_edition
  end

  should 'a submission and parent attribute "published" be equal to Work Assignment attribute publish submissions' do
    @organization.add_member(@person)
    work_assignment = create_work_assignment('Work Assignment', @organization, true, nil)
    assert_equal true, work_assignment.publish_submissions
    post :upload_files, :profile => @organization.identifier, :parent_id => work_assignment.id, :uploaded_files => [fixture_file_upload('/files/test.txt', 'text/plain')]
    submission = UploadedFile.last
    assert_equal work_assignment.publish_submissions, submission.published
    assert_equal work_assignment.publish_submissions, submission.parent.published

    other_work_assignment = create_work_assignment('Other Work Assigment', @organization, false, nil)
    assert_equal false, other_work_assignment.publish_submissions
    post :upload_files, :profile => @organization.identifier, :parent_id => other_work_assignment.id, :uploaded_files => [fixture_file_upload('/files/test.txt', 'text/plain')]
    submission = UploadedFile.last
    assert_equal other_work_assignment.publish_submissions, submission.published
    assert_equal other_work_assignment.publish_submissions, submission.parent.published
  end

  private
    def create_work_assignment(name = nil, profile = nil, publish_submissions = nil, allow_visibility_edition = nil)
      @work_assignment = WorkAssignmentPlugin::WorkAssignment.create!(:name => name, :profile => profile, :publish_submissions => publish_submissions, :allow_visibility_edition => allow_visibility_edition)
    end
end
