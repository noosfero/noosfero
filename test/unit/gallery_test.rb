require_relative "../test_helper"

class GalleryTest < ActiveSupport::TestCase

  should 'be an article' do
    assert_kind_of Article, Gallery.new
  end

  should 'provide proper description' do
    assert_kind_of String, Gallery.description
  end

  should 'provide proper short description' do
    assert_kind_of String, Gallery.short_description
  end

  should 'provide own icon name' do
    assert_not_equal Article.icon_name, Gallery.icon_name
  end

  should 'provide gallery as icon name' do
    assert_not_equal Article.icon_name, Gallery.icon_name
  end

  should 'identify as folder' do
    assert Folder.new.folder?, 'gallery must identity itself as folder'
  end

  should 'identify as gallery' do
    assert Gallery.new.gallery?, 'gallery must identity itself as gallery'
  end

  should 'can display hits' do
    profile = create_user('testuser').person
    a = fast_create(Gallery, :profile_id => profile.id)
    assert_equal false, a.can_display_hits?
  end

  should 'have images that are only images or other galleries' do
    p = create_user('test_user').person
    f = fast_create(Gallery, :profile_id => p.id)
    file = create(UploadedFile, :uploaded_data => fixture_file_upload('/files/test.txt', 'text/plain'), :parent => f, :profile => p)
    image = create(UploadedFile, :uploaded_data => fixture_file_upload('/files/rails.png', 'image/png'), :parent => f, :profile => p)
    gallery = fast_create(Gallery, :profile_id => p.id, :parent_id => f.id)

    assert_equivalent [gallery, image], f.images
  end

  should 'bring galleries first in alpha order in images listing' do
    p = create_user('test_user').person
    f = fast_create(Gallery, :profile_id => p.id)
    gallery1 = fast_create(Gallery, :name => 'b', :profile_id => p.id, :parent_id => f.id)
    image = create(UploadedFile, :uploaded_data => fixture_file_upload('/files/rails.png', 'image/png'), :parent => f, :profile => p)
    gallery2 = fast_create(Gallery, :name => 'c', :profile_id => p.id, :parent_id => f.id)
    gallery3 = fast_create(Gallery, :name => 'a', :profile_id => p.id, :parent_id => f.id)

    assert_equal [gallery3.id, gallery1.id, gallery2.id, image.id], f.images.map(&:id)
  end

  should 'images support pagination' do
    p = create_user('test_user').person
    f = fast_create(Gallery, :profile_id => p.id)
    gallery = fast_create(Gallery, :profile_id => p.id, :parent_id => f.id)
    image = create(UploadedFile, :uploaded_data => fixture_file_upload('/files/rails.png', 'image/png'), :parent => f, :profile => p)

    assert_equal [image], f.images.paginate(:page => 2, :per_page => 1)
  end

  should 'return newest text articles as news' do
    c = fast_create(Community)
    gallery = fast_create(Gallery, :profile_id => c.id)
    f = fast_create(Gallery, :name => 'gallery', :profile_id => c.id, :parent_id => gallery.id)
    u = create(UploadedFile, :profile => c, :uploaded_data => fixture_file_upload('/files/rails.png', 'image/png'), :parent => gallery)
    older_t = fast_create(TinyMceArticle, :name => 'old news', :profile_id => c.id, :parent_id => gallery.id)
    t = fast_create(TinyMceArticle, :name => 'news', :profile_id => c.id, :parent_id => gallery.id)
    t_in_f = fast_create(TinyMceArticle, :name => 'news', :profile_id => c.id, :parent_id => f.id)

    assert_equal [t], gallery.news(1)
  end

  should 'not return highlighted news when not asked' do
    c = fast_create(Community)
    gallery = fast_create(Gallery, :profile_id => c.id)
    highlighted_t = fast_create(TinyMceArticle, :name => 'high news', :profile_id => c.id, :highlighted => true, :parent_id => gallery.id)
    t = fast_create(TinyMceArticle, :name => 'news', :profile_id => c.id, :parent_id => gallery.id)

    assert_equal [t].map(&:slug), gallery.news(2).map(&:slug)
  end

  should 'return highlighted news when asked' do
    c = fast_create(Community)
    gallery = fast_create(Gallery, :profile_id => c.id)
    highlighted_t = fast_create(TinyMceArticle, :name => 'high news', :profile_id => c.id, :highlighted => true, :parent_id => gallery.id)
    t = fast_create(TinyMceArticle, :name => 'news', :profile_id => c.id, :parent_id => gallery.id)

    assert_equal [highlighted_t].map(&:slug), gallery.news(2, true).map(&:slug)
  end

  should 'return published images as images' do
    p = create_user('test_user').person
    i = UploadedFile.create!(:profile => p, :uploaded_data => fixture_file_upload('/files/rails.png', 'image/png'))

    c = fast_create(Community)
    c.add_member(p)
    gallery = fast_create(Gallery, :profile_id => c.id)

    a = create(ApproveArticle, :article => i, :target => c, :requestor => p, :article_parent => gallery)
    a.finish

    assert_includes gallery.images(true), c.articles.find_by_name('rails.png')
  end

  should 'not let pass javascript in the body' do
    gallery = Gallery.new
    gallery.body = "<script> alert(Xss!); </script>"
    gallery.valid?

    assert_no_match /(<script>)/, gallery.body
  end

  should 'filter fields with white_list filter' do
    gallery = Gallery.new
    gallery.body = "<h1> Body </h1>"
    gallery.valid?

    assert_equal "<h1> Body </h1>", gallery.body
  end

  should 'not sanitize html comments' do
    gallery = Gallery.new
    gallery.body = '<p><!-- <asdf> << aasdfa >>> --> <h1> Wellformed html code </h1>'
    gallery.valid?

    assert_match  /<p><!-- .* --> <\/p><h1> Wellformed html code <\/h1>/, gallery.body
  end

  should 'accept uploads' do
    folder = fast_create(Gallery)
    assert folder.accept_uploads?
  end

end
