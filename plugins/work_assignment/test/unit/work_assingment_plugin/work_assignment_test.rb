require 'test_helper'

class WorkAssignmentTest < ActiveSupport::TestCase
  should 'find or create sub-folder based on author identifier' do
    profile = fast_create(Profile)
    author = fast_create(Person)
    work_assignment = WorkAssignmentPlugin::WorkAssignment.create!(:name => 'Sample Work Assignment', :profile => profile)
    assert_nil work_assignment.children.find_by slug: author.identifier

    folder = work_assignment.find_or_create_author_folder(author)
    assert_not_nil work_assignment.children.find_by slug: author.identifier
    assert_equal folder, work_assignment.find_or_create_author_folder(author)
  end

  should 'return versioned name' do
    profile = fast_create(Profile)
    folder = fast_create(Folder, :profile_id => profile)
    a1 = Article.create!(:name => "Article 1", :profile => profile)
    a2 = Article.create!(:name => "Article 2", :profile => profile)
    a3 = Article.create!(:name => "Article 3", :profile => profile)
    klass = WorkAssignmentPlugin::WorkAssignment

    assert_equal "(V1) #{a1.name}", klass.versioned_name(a1, folder)

    a1.parent = folder
    a1.save!
    assert_equal "(V2) #{a2.name}", klass.versioned_name(a2, folder)

    a2.parent = folder
    a2.save!
    assert_equal "(V3) #{a3.name}", klass.versioned_name(a3, folder)
  end

  should 'move submission to its correct author folder' do
    organization = fast_create(Organization)
    author = fast_create(Person)
    work_assignment = WorkAssignmentPlugin::WorkAssignment.create!(:name => 'Sample Work Assignment', :profile => organization)
    submission = create(UploadedFile, :uploaded_data => fixture_file_upload('/files/rails.png', 'image/png'), :profile => organization, :parent => work_assignment, :author => author)

    author_folder = work_assignment.find_or_create_author_folder(author)
    assert_equal author_folder, submission.parent
  end

  should 'add logged user on cache_key if is a member' do
    organization = fast_create(Organization)
    not_member = fast_create(Person)
    member = fast_create(Person)
    organization.add_member(member)
    work_assignment = WorkAssignmentPlugin::WorkAssignment.create!(:name => 'Sample Work Assignment', :profile => organization)

    assert_no_match(/-#{not_member.identifier}/, work_assignment.cache_key({}, not_member))
    assert_match(/-#{member.identifier}/, work_assignment.cache_key({}, member))
  end

end
