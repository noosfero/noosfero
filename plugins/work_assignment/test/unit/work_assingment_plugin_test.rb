require 'test_helper'

class WorkAssignmentPluginTest < ActiveSupport::TestCase
  should 'verify if a content is a work_assignment submission' do
    organization = fast_create(Organization)
    content = UploadedFile.create!(:uploaded_data => fixture_file_upload('/files/rails.png', 'image/png'), :profile => organization, :last_changed_by => fast_create(Person))
    assert !WorkAssignmentPlugin.is_submission?(content)

    work_assignment = WorkAssignmentPlugin::WorkAssignment.create!(:name => 'Work Assignment', :profile => organization)
    content.parent = work_assignment
    content.save!
    assert WorkAssignmentPlugin.is_submission?(content)

    author_folder = work_assignment.find_or_create_author_folder(content.author)
    assert_equal author_folder, content.parent
  end

  should 'be able to download submission if work_assignment published submissions' do
    submission = create_submission
    assert !WorkAssignmentPlugin.can_download_submission?(nil, submission)

    work_assignment = submission.parent.parent
    work_assignment.publish_submissions = true
    work_assignment.save!
    assert WorkAssignmentPlugin.can_download_submission?(nil, submission)
  end

  should 'be able to download submission if the user is author of it' do
    person = fast_create(Person)
    submission = create_submission
    assert !WorkAssignmentPlugin.can_download_submission?(person, submission)

    submission = create_submission(person)
    assert WorkAssignmentPlugin.can_download_submission?(person, submission)
  end

  should 'be able to download submission if the user has the view_private_content permission on the profile' do
    person = fast_create(Person)
    submission = create_submission
    assert !WorkAssignmentPlugin.can_download_submission?(person, submission)

    moderator = create_user_with_permission('moderator', 'view_private_content', submission.profile)
    assert WorkAssignmentPlugin.can_download_submission?(moderator, submission)
  end

  private

  def create_submission(author=nil)
    organization = fast_create(Organization)
    work_assignment = WorkAssignmentPlugin::WorkAssignment.create!(:name => 'Work Assignment', :profile => organization)
    author_folder = work_assignment.find_or_create_author_folder(fast_create(Person))
    UploadedFile.create!(:uploaded_data => fixture_file_upload('/files/rails.png', 'image/png'), :profile => organization, :parent => author_folder, :last_changed_by => author)
  end
end
