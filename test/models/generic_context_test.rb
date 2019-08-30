require_relative "../test_helper"

class GenericContextTest < ActiveSupport::TestCase
  def setup
    @test_user = create_user("test_user").person
    @community_can_post = fast_create(Community, name: "community with permission")
    @community_can_post.add_admin(@test_user)
    @community_can_not_post = fast_create(Community, name: "community without permission")
  end

  attr :test_user
  attr :community_can_post
  attr :community_can_not_post

  should "return sensitive content types to generic context" do
    current_page = fast_create(TextArticle, profile_id: community_can_post.id)

    context = GenericContext.set_context(test_user, current_page,
                                         community_can_post)

    assert context.content_types.length == 8
    assert context.content_types.include?(TextArticle)
    assert context.content_types.include?(Event)
    assert context.content_types.include?(RssFeed)
    assert context.content_types.include?(Folder)
    assert context.content_types.include?(Blog)
    assert context.content_types.include?(UploadedFile)
    assert context.content_types.include?(Forum)
    assert context.content_types.include?(Gallery)
  end

  should "set context with params received" do
    current_page = fast_create(TextArticle, profile_id: community_can_post.id)

    context = GenericContext.set_context(test_user, current_page,
                                         community_can_post)

    assert_equal test_user, context.current_user
    assert_equal current_page, context.current_page
    assert_equal community_can_post, context.selected_profile
  end

  should "return GenericContext if current page is nil" do
    current_page = nil

    context = GenericContext.set_context(test_user, current_page,
                                         community_can_post)

    assert_equal GenericContext, context.class
  end

  should "return BlogContext if current page is a blog" do
    current_page = fast_create(Blog, profile_id: community_can_post.id)

    context = GenericContext.set_context(test_user, current_page,
                                         community_can_post)

    assert_equal BlogContext, context.class
  end

  should "return BlogContext if current page belongs to a blog" do
    parent = fast_create(Blog, profile_id: community_can_post.id)

    current_page = fast_create(TextArticle, parent_id: parent.id)

    context = GenericContext.set_context(test_user, current_page,
                                         community_can_post)

    assert_equal BlogContext, context.class
  end

  should "return GalleryContext if current page is a gallery" do
    current_page = fast_create(Gallery, profile_id: community_can_post.id)

    context = GenericContext.set_context(test_user, current_page,
                                         community_can_post)

    assert_equal GalleryContext, context.class
  end

  should "return GalleryContext if current page belongs to a gallery" do
    parent = fast_create(Gallery, profile_id: community_can_post.id)

    current_page = fast_create(TextArticle, parent_id: parent.id)

    context = GenericContext.set_context(test_user, current_page,
                                         community_can_post)

    assert_equal GalleryContext, context.class
  end

  should "return FolderContext if current page is a folder" do
    current_page = fast_create(Folder, profile_id: community_can_post.id)

    context = GenericContext.set_context(test_user, current_page,
                                         community_can_post)

    assert_equal FolderContext, context.class
  end

  should "return FolderContext if current page belongs to a folder" do
    parent = fast_create(Folder, profile_id: community_can_post.id)

    current_page = fast_create(TextArticle, parent_id: parent.id)

    context = GenericContext.set_context(test_user, current_page,
                                         community_can_post)

    assert_equal FolderContext, context.class
  end

  should "return ForumContext if current page is a forum" do
    current_page = fast_create(Forum, profile_id: community_can_post.id)

    context = GenericContext.set_context(test_user, current_page,
                                         community_can_post)

    assert_equal ForumContext, context.class
  end

  should "return ForumContext if current page belongs to a forum" do
    parent = fast_create(Forum, profile_id: community_can_post.id)

    current_page = fast_create(TextArticle, parent_id: parent.id)

    context = GenericContext.set_context(test_user, current_page,
                                         community_can_post)

    assert_equal ForumContext, context.class
  end

  should "return GenericContext if parent to current page is nil and current page isn't folder" do
    current_page = fast_create(TextArticle, parent_id: nil)

    context = GenericContext.set_context(test_user, current_page,
                                         community_can_post)

    assert_equal GenericContext, context.class
  end

  should "return GenericContext if don't has sensitive context defined to page" do
    class TestArticle < Article; end

    current_page = fast_create(TestArticle, profile_id: community_can_post.id)

    context = GenericContext.set_context(test_user, current_page,
                                         community_can_post)

    assert_equal GenericContext, context.class
  end

  should "return GenericContext if don't has sensitive context defined to folder page" do
    class TestFolder < Folder; end

    current_page = fast_create(TestFolder, profile_id: community_can_post.id)

    context = GenericContext.set_context(test_user, current_page,
                                         community_can_post)

    assert_equal GenericContext, context.class
  end

  should "return true if the user has permission to publish in profile" do
    assert GenericContext.publish_permission? community_can_post, test_user
  end

  should "return false if the user hasn't permission to publish in profile" do
    refute GenericContext.publish_permission? community_can_not_post, test_user
  end

  should "return that the user hasn't persmission to publish if the profile is nil" do
    refute GenericContext.publish_permission? nil, test_user
  end

  should "return true if the user is in your own profile" do
    assert GenericContext.publish_permission? test_user, test_user
  end

  should "return false if the user is in profile of another user" do
    another_user = create_user("another_user").person
    refute GenericContext.publish_permission? another_user, test_user
  end

  should "return current profile if current user has permission to publish in profile" do
    current_page = fast_create(TextArticle, profile_id: community_can_post.id)

    context = GenericContext.set_context(test_user, current_page,
                                         community_can_post)

    assert_equal community_can_post, context.selected_profile
  end

  should "return user profile if current user hasn't permission to publish in profile" do
    current_page = fast_create(TextArticle, profile_id: community_can_not_post.id)

    context = GenericContext.set_context(test_user, current_page,
                                         community_can_not_post)

    assert_equal test_user, context.selected_profile
  end

  should "return user profile if current profile belongs to another user" do
    another_user = create_user("another_user").person
    current_page = fast_create(TextArticle, profile_id: another_user)

    context = GenericContext.set_context(test_user, current_page,
                                         another_user)

    assert_equal test_user, context.selected_profile
  end

  should "return directory of current page if user has publish permission in current profile" do
    parent_folder = fast_create(Folder, profile_id: community_can_post.id)
    current_page = fast_create(TextArticle, profile_id: community_can_post.id, parent_id: parent_folder.id)

    context = GenericContext.set_context(test_user, current_page,
                                         community_can_post)

    assert_equal parent_folder, context.directory_to_publish
  end

  should 'return nil if current page has\'t directory and \\
          user has publish permission in current profile' do
    current_page = fast_create(TextArticle, profile_id: community_can_post.id, parent_id: nil)

    context = GenericContext.set_context(test_user, current_page,
                                         community_can_post)

    assert_nil context.directory_to_publish
  end

  should 'return current page if current page is a directory and \\
          user has publish permission in current profile' do
    current_page = fast_create(Folder, profile_id: community_can_post.id)

    context = GenericContext.set_context(test_user, current_page,
                                         community_can_post)

    assert_equal current_page, context.directory_to_publish
  end

  should 'return sensitive directory if the selected profile is different \\
          from the current profile' do
    current_page = fast_create(TextArticle, profile_id: community_can_not_post.id,
                                            parent_id: nil)

    context = GenericContext.set_context(test_user, current_page,
                                         community_can_not_post)

    assert_nil context.directory_to_publish
    assert_equal test_user, context.selected_profile
  end

  should "return subdirectories in root's profile" do
    folder = fast_create(Folder, profile_id: community_can_post)
    subfolder = fast_create(Blog, profile_id: community_can_post,
                                  parent_id: folder.id)

    context = GenericContext.set_context(test_user, nil, community_can_post, true)

    assert_includes context.directory_options, folder
    assert_not_includes context.directory_options, subfolder
    assert_equal community_can_post, context.selected_profile
  end

  should "return subdirectories in folder if selected_directory is true" do
    folder = fast_create(Folder, profile_id: community_can_post)
    subfolder = fast_create(Blog, profile_id: community_can_post,
                                  parent_id: folder.id)

    context = GenericContext.set_context(test_user, folder,
                                         community_can_post, true)

    assert_includes context.directory_options, subfolder
    assert_not_includes context.directory_options, folder
    assert_equal community_can_post, context.selected_profile
  end

  should "return alternative context if current page not has a context defined" do
    current_page = fast_create(Event, profile_id: community_can_post.id)

    context = GenericContext.set_context(test_user, current_page,
                                         community_can_post, false, "Agenda")

    assert_equal AgendaContext, context.class
  end
end
