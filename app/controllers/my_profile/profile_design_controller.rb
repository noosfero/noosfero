class ProfileDesignController < BoxOrganizerController

  needs_profile

  def available_blocks
    blocks = [ ArticleBlock, TagsBlock, RecentDocumentsBlock, ProfileInfoBlock ]

    if profile.has_members?
      blocks << MembersBlock
    end

    blocks
  end

end
