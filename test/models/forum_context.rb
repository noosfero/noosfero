require_relative "../test_helper"

class GenericContextTest < ActiveSupport::TestCase

  def setup
    @test_user = create_user('test_user').person
    @community_can_post = fast_create(Community, name: 'community with permission')
    @community_can_post.add_admin(@test_user)
    @community_can_not_post = fast_create(Community, name: 'community without permission')
  end

  attr :test_user
  attr :community_can_post
  attr :community_can_not_post

  should 'return sensitive content types to forum' do


    current_page = fast_create(Forum, profile_id: community_can_post.id)

    context = GenericContext.set_context(test_user, current_page,
                                          community_can_post)

    assert context.content_types.length == 3
    assert context.content_types.include?(TextArticle)
    assert context.content_types.include?(Event)
    assert context.content_types.include?(UploadedFile)
  end

  should 'return sensitive forum directory if the selected profile is different \\
          from the current profile and current page belongs to forum' do

    user_forum = fast_create(Forum, profile_id: test_user.id)

    current_forum = fast_create(Forum, profile_id: community_can_not_post.id)

    current_page = fast_create(TextArticle, profile_id: community_can_not_post.id,
                                parent_id: current_forum.id)

    context = GenericContext.set_context(test_user, current_page,
                                          community_can_not_post)

    assert_equal user_forum, context.directory_to_publish
    assert_equal test_user, context.selected_profile
  end

  should 'return nil if the selected profile is different \\
          from the current profile and current page belongs to forum \\
          and the user has\'t forums in your profile' do

    current_forum = fast_create(Forum, profile_id: community_can_not_post.id)

    current_page = fast_create(TextArticle, profile_id: community_can_not_post.id,
                                parent_id: current_forum.id)

    context = GenericContext.set_context(test_user, current_page,
                                          community_can_not_post)

    assert_nil context.directory_to_publish
    assert_equal test_user, context.selected_profile
  end
end
