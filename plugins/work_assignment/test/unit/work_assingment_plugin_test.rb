require 'test_helper'

class WorkAssignmentPluginTest < ActiveSupport::TestCase
  should 'verify if a content is a work_assignment submission' do
    organization = fast_create(Organization)
    folder = fast_create(Folder)
    person = fast_create(Person)
    content = UploadedFile.create(
            {
              :uploaded_data => fixture_file_upload('/files/rails.png', 'image/png'),
              :profile => organization,
              :parent => folder,
              :last_changed_by => person,
              :author => person,
            },
            :without_protection => true
          )
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

    other_submission = create_submission(nil, work_assignment)
    assert WorkAssignmentPlugin.can_download_submission?(nil, other_submission)
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

  def create_submission(author=nil, work_assignment=nil)
    author ||= fast_create(Person)
    organization = fast_create(Organization)
    organization.add_member(author)
    work_assignment ||= WorkAssignmentPlugin::WorkAssignment.create!(:name => 'Work Assignment', :profile => organization)
    author_folder = work_assignment.find_or_create_author_folder(author)
    content = UploadedFile.create(
            {
              :uploaded_data => fixture_file_upload('/files/rails.png', 'image/png'),
              :profile => organization,
              :parent => author_folder,
              :last_changed_by => author,
              :author => author,
            },
            :without_protection => true
          )
  end
end
