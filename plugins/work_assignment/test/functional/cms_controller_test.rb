require File.expand_path(File.dirname(__FILE__) + "/../../../../test/test_helper")
require 'cms_controller'

# Re-raise errors caught by the controller.
class CmsController; def rescue_action(e) raise e end; end

class CmsControllerTest < ActionController::TestCase

  include NoosferoTestHelper

  fixtures :environments


  attr_reader :profile
  attr_accessor :person

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
    work_assignment = create_work_assignment('Another Work Assignment', @organization, nil, nil)
    get :upload_files, :profile => @organization.identifier, :parent_id => work_assignment.id
    assert_response :forbidden
    assert_template 'access_denied'
  end

  should 'allow members to upload submissions on work_assignment' do
    @organization.add_member(person)
    # then he trys to upload new stuff
    work_assignment = create_work_assignment('Another Work Assignment', @organization, nil, nil)
    get :upload_files, :profile => @organization.identifier, :parent_id => work_assignment.id
    assert_response :success
  end

  should 'redirect to Work Assignment view page after upload submission' do
    @organization.add_member(person)
    work_assignment = create_work_assignment('Another Work Assignment', @organization, nil, nil)
    post :upload_files, :profile => @organization.identifier, :parent_id => work_assignment.id, :uploaded_files => [fixture_file_upload('/files/test.txt', 'text/plain')] , :back_to => @work_assignment.url
    assert_redirected_to work_assignment.url
  end

  should 'upload submission and automatically move it to the author folder' do
    work_assignment = create_work_assignment('Another Work Assignment', @organization, nil, nil)
    @organization.add_member(person)
    post :upload_files, :profile => @organization.identifier, :parent_id => work_assignment.id, :uploaded_files => [fixture_file_upload('/files/test.txt', 'text/plain')]
    submission = UploadedFile.last
    assert_equal work_assignment.find_or_create_author_folder(person), submission.parent
  end

  should 'work_assignment attribute allow_privacy_edition is true when set a new work_assignment' do
    work_assignment = create_work_assignment('Another Work Assignment', @organization, nil, true)
    @organization.add_member(person)
    assert_equal true, work_assignment.allow_privacy_edition
  end

  should 'a submission and parent attribute "published" be equal to Work Assignment attribute publish submissions' do
    @organization.add_member(person)
    work_assignment = create_work_assignment('Another Work Assignment', @organization, true, nil)
    assert_equal true, work_assignment.publish_submissions
    post :upload_files, :profile => @organization.identifier, :parent_id => work_assignment.id, :uploaded_files => [fixture_file_upload('/files/test.txt', 'text/plain')]
    submission = UploadedFile.last
    assert_equal work_assignment.publish_submissions, submission.published
    assert_equal work_assignment.publish_submissions, submission.parent.published

    other_work_assignment = create_work_assignment('Another Other Work Assigment', @organization, false, nil)
    assert_equal false, other_work_assignment.publish_submissions
    post :upload_files, :profile => @organization.identifier, :parent_id => other_work_assignment.id, :uploaded_files => [fixture_file_upload('/files/test.txt', 'text/plain')]
    submission = UploadedFile.last
    assert_equal other_work_assignment.publish_submissions, submission.published
    assert_equal other_work_assignment.publish_submissions, submission.parent.published
  end

  should 'submission edit visibility deny access to users and admin when Work Assignment allow_privacy_edition is false' do
    @organization.add_member(person)
    ##### Testing with normal user
    work_assignment = create_work_assignment('Another Work Assignment', @organization, nil, nil)
    post :upload_files, :profile => @organization.identifier, :parent_id => work_assignment.id, :uploaded_files => [fixture_file_upload('/files/test.txt', 'text/plain')]
    submission = UploadedFile.last
    assert_equal false, submission.published
    assert_equal false, submission.parent.published

    post :edit_visibility, :profile => @organization.identifier, :article_id => submission.parent.id
    assert_template 'access_denied'
    post :edit_visibility, :profile => @organization.identifier, :article_id => submission.parent.id, :article => { :published => true }
    assert_template 'access_denied'

    submission.reload
    assert_equal false, submission.published
    assert_equal false, submission.parent.published

    #### Even with admin user
    e = Environment.default
    assert_equal false, person.is_admin?
    e.add_admin(person)
    e.save!
    assert_equal true, person.is_admin?

    post :edit_visibility, :profile => @organization.identifier, :article_id => submission.parent.id
    assert_template 'access_denied'
    post :edit_visibility, :profile => @organization.identifier, :article_id => submission.parent.id, :article => { :published => true }
    assert_template 'access_denied'

    submission.reload
    assert_equal false, submission.published
  end

  should 'redirect an unlogged user to the login page if he tryes to access the edit visibility page and work_assignment allow_privacy_edition is true' do
    @organization.add_member(person)
    work_assignment = create_work_assignment('Another Work Assignment', @organization, nil, nil)
    work_assignment.allow_privacy_edition = true # the user can edit the privacy
    assert_equal true, work_assignment.allow_privacy_edition
    work_assignment.save!
    parent = work_assignment.find_or_create_author_folder(person)
    UploadedFile.create(
            {
              :uploaded_data => fixture_file_upload('/files/test.txt', 'text/plain'),
              :profile => @organization,
              :parent => parent,
              :last_changed_by => person,
              :author => person,
            },
            :without_protection => true
          )
    logout
    submission = UploadedFile.last
    assert_equal false, submission.parent.published
    assert_equal false, submission.published

    post :edit_visibility, :profile => @organization.identifier, :article_id => submission.parent.id
    assert_redirected_to '/account/login'
    post :edit_visibility, :profile => @organization.identifier, :article_id => submission.parent.id, :article => { :published => true }
    assert_redirected_to '/account/login'
    submission.reload
    assert_equal false, submission.parent.published
    assert_equal false, submission.published
  end

  should 'submission edit_visibility deny access to not owner when WorkAssignment edit_visibility is true' do
    @organization.add_member(person) # current_user is a member
    work_assignment = create_work_assignment('Another Work Assignment', @organization, nil, true)
    @parent = work_assignment.find_or_create_author_folder(person)
    UploadedFile.create(
            {
              :uploaded_data => fixture_file_upload('/files/test.txt', 'text/plain'),
              :profile => @organization,
              :parent => @parent,
              :last_changed_by => person,
              :author => person,
            },
            :without_protection => true
          )
    logout


    other_person = create_user('other_user').person
    @organization.add_member(other_person)
    login_as :other_user

    @organization.add_member(other_person)
    submission = UploadedFile.last
    assert_equal(submission.author, person)

    post :edit_visibility, :profile => @organization.identifier, :article_id => submission.parent.id
    assert_template 'access_denied'

    post :edit_visibility, :profile => @organization.identifier, :article_id => submission.parent.id, :article => { :published => true }
    assert_template 'access_denied'

    submission.reload
    assert_equal false, submission.parent.published
    assert_equal false, submission.published
  end

  should 'submission white list give permission to an user that has been added' do
    other_person = create_user('other_user').person
    @organization.add_member(person)
    @organization.add_member(other_person)
    work_assignment = create_work_assignment('Another Work Assignment', @organization, false,  true)
    post :upload_files, :profile => @organization.identifier, :parent_id => work_assignment.id, :uploaded_files => [fixture_file_upload('/files/test.txt', 'text/plain')]
    submission = UploadedFile.last
    assert_equal false, submission.display_unpublished_article_to?(other_person)
    post :edit_visibility, :profile => @organization.identifier, :article_id  => submission.parent.id, :article => { :published => false }, :q => other_person.id
    submission.reload
    assert_equal true, submission.parent.display_unpublished_article_to?(other_person)
    assert_equal true, submission.display_unpublished_article_to?(other_person)
  end

  private
    def create_work_assignment(name = nil, profile = nil, publish_submissions = nil, allow_privacy_edition = nil)
      @work_assignment = WorkAssignmentPlugin::WorkAssignment.create!(:name => name, :profile => profile, :publish_submissions => publish_submissions, :allow_privacy_edition => allow_privacy_edition)
    end
end
