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

  should "return sensitive content types to gallery" do
    current_page = fast_create(Gallery, profile_id: community_can_post.id)

    context = GenericContext.set_context(test_user, current_page,
                                         community_can_post)

    assert context.content_types.length == 1
    assert context.content_types.include?(UploadedFile)
  end

  should 'return sensitive gallery directory if the selected profile is different \\
          from the current profile and current page belongs to gallery' do
    user_gallery = fast_create(Gallery, profile_id: test_user.id)

    current_gallery = fast_create(Gallery, profile_id: community_can_not_post.id)

    current_page = fast_create(TextArticle, profile_id: community_can_not_post.id,
                                            parent_id: current_gallery.id)

    context = GenericContext.set_context(test_user, current_page,
                                         community_can_not_post)

    assert_equal user_gallery, context.directory_to_publish
    assert_equal test_user, context.selected_profile
  end

  should 'return nil if the selected profile is different \\
          from the current profile and current page belongs to gallery \\
          and the user has\'t gallerys in your profile' do
    current_gallery = fast_create(Gallery, profile_id: community_can_not_post.id)

    current_page = fast_create(TextArticle, profile_id: community_can_not_post.id,
                                            parent_id: current_gallery.id)

    context = GenericContext.set_context(test_user, current_page,
                                         community_can_not_post)

    assert_nil context.directory_to_publish
    assert_equal test_user, context.selected_profile
  end
end
