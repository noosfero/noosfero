class ProfileDesignController < BoxOrganizerController

  needs_profile

  def available_blocks
    blocks = [ ArticleBlock, TagsBlock, RecentDocumentsBlock, ProfileInfoBlock ]

    # blocks exclusive for organizations
    if profile.has_members?
      blocks << MembersBlock
    end

    if profile.person?
      blocks << FriendsBlock
    end

    blocks
  end

end
