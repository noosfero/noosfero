require_relative "../test_helper"

class SensitiveContentTest < ActiveSupport::TestCase

  def setup
    @test_user = create_user('test_user').person
    @community_can_post = fast_create(Community, name: 'community with permission')
    @community_can_post.add_admin(@test_user)
    @community_can_not_post = fast_create(Community, name: 'community without permission')
  end

  attr :test_user
  attr :community_can_post
  attr :community_can_not_post

end
