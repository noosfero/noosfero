require_relative "../test_helper"

class FolderTest < ActiveSupport::TestCase

  should 'be an article' do
    assert_kind_of Article, Folder.new
  end

  should 'provide proper description' do
    assert_kind_of String, Folder.description
  end

  should 'provide proper short description' do
    assert_kind_of String, Folder.short_description
  end

  should 'provide own icon name' do
    assert_not_equal Article.icon_name, Folder.icon_name
  end

  should 'identify as folder' do
    assert Folder.new.folder?, 'folder must identity itself as folder'
  end

  should 'can display hits' do
    profile = create_user('testuser').person
    a = fast_create(Folder, :profile_id => profile.id)
    assert_equal false, a.can_display_hits?
  end

  should 'have images that are only images or other folders' do
    p = create_user('test_user').person
    f = fast_create(Folder, :profile_id => p.id)
    file = create(UploadedFile, :uploaded_data => fixture_file_upload('/files/test.txt', 'text/plain'), :parent => f, :profile => p)
    image = create(UploadedFile, :uploaded_data => fixture_file_upload('/files/rails.png', 'image/png'), :parent => f, :profile => p)
    folder = fast_create(Folder, :profile_id => p.id, :parent_id => f.id)

    assert_equivalent [folder, image], f.images
  end

  should 'bring folders first in alpha order in images listing' do
    p = create_user('test_user').person
    f = fast_create(Folder, :profile_id => p.id)
    folder1 = fast_create(Folder, :name => 'b', :profile_id => p.id, :parent_id => f.id)
    image = create(UploadedFile, :uploaded_data => fixture_file_upload('/files/rails.png', 'image/png'), :parent => f, :profile => p)
    folder2 = fast_create(Folder, :name => 'c', :profile_id => p.id, :parent_id => f.id)
    folder3 = fast_create(Folder, :name => 'a', :profile_id => p.id, :parent_id => f.id)

    assert_equal [folder3.id, folder1.id, folder2.id, image.id], f.images.map(&:id)
  end

  should 'images support pagination' do
    p = create_user('test_user').person
    f = fast_create(Folder, :profile_id => p.id)
    folder = fast_create(Folder, :profile_id => p.id, :parent_id => f.id)
    image = create(UploadedFile, :uploaded_data => fixture_file_upload('/files/rails.png', 'image/png'), :parent => f, :profile => p)

    assert_equal [image], f.images.paginate(:page => 2, :per_page => 1)
  end

  should 'return newest text articles as news' do
    c = fast_create(Community)
    folder = fast_create(Folder, :profile_id => c.id)
    f = fast_create(Folder, :name => 'folder', :profile_id => c.id, :parent_id => folder.id)
    u = create(UploadedFile, :profile => c, :uploaded_data => fixture_file_upload('/files/rails.png', 'image/png'), :parent => folder)
    older_t = fast_create(TinyMceArticle, :name => 'old news', :profile_id => c.id, :parent_id => folder.id)
    t = fast_create(TinyMceArticle, :name => 'news', :profile_id => c.id, :parent_id => folder.id)
    t_in_f = fast_create(TinyMceArticle, :name => 'news', :profile_id => c.id, :parent_id => f.id)

    assert_equal [t], folder.news(1)
  end

  should 'not return highlighted news when not asked' do
    c = fast_create(Community)
    folder = fast_create(Folder, :profile_id => c.id)
    highlighted_t = fast_create(TinyMceArticle, :name => 'high news', :profile_id => c.id, :highlighted => true, :parent_id => folder.id)
    t = fast_create(TinyMceArticle, :name => 'news', :profile_id => c.id, :parent_id => folder.id)

    assert_equal [t].map(&:slug), folder.news(2).map(&:slug)
  end

  should 'return highlighted news when asked' do
    c = fast_create(Community)
    folder = fast_create(Folder, :profile_id => c.id)
    highlighted_t = fast_create(TinyMceArticle, :name => 'high news', :profile_id => c.id, :highlighted => true, :parent_id => folder.id)
    t = fast_create(TinyMceArticle, :name => 'news', :profile_id => c.id, :parent_id => folder.id)

    assert_equal [highlighted_t].map(&:slug), folder.news(2, true).map(&:slug)
  end

  should 'return published images as images' do
    person = create_user('test_user').person
    image = UploadedFile.create!(:profile => person, :uploaded_data => fixture_file_upload('/files/rails.png', 'image/png'))

    community = fast_create(Community)
    community.add_member(person)
    folder = fast_create(Folder, :profile_id => community.id)
    a = create(ApproveArticle, :article => image, :target => community, :requestor => person, :article_parent => folder)
    a.finish

    assert_includes folder.images(true), community.articles.find_by(name: 'rails.png')
  end

  should 'not let pass javascript in the name' do
    folder = Folder.new
    folder.name = "<script> alert(Xss!); </script>"
    folder.valid?

    assert_no_match /(<script>)/, folder.name
  end

  should 'not let pass javascript in the body' do
    folder = Folder.new
    folder.body = "<script> alert(Xss!); </script>"
    folder.valid?

    assert_no_match /(<script>)/, folder.body
  end

  should 'filter fields with white_list filter' do
    folder = Folder.new
    folder.body = "<h1> Body </h1>"
    folder.valid?

    assert_equal "<h1> Body </h1>", folder.body
  end

  should 'not sanitize html comments' do
    folder = Folder.new
    folder.body = '<p><!-- <asdf> << aasdfa >>> --> <h1> Wellformed html code </h1>'
    folder.valid?

    assert_match  /<p><!-- .* --> <\/p><h1> Wellformed html code <\/h1>/, folder.body
  end

  should 'not have a blog as parent' do
    folder = Folder.new
    folder.parent = Blog.new
    folder.valid?

    assert folder.errors[:parent].present?
  end

  should 'accept uploads' do
    folder = fast_create(Folder)
    assert folder.accept_uploads?
  end

end
