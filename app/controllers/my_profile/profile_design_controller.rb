class ProfileDesignController < BoxOrganizerController

  needs_profile

  protect 'edit_profile_design', :profile
  
  def available_blocks
    blocks = [ ArticleBlock, TagsBlock, RecentDocumentsBlock, ProfileInfoBlock, LinkListBlock ]

    # blocks exclusive for organizations
    if profile.has_members?
      blocks << MembersBlock
    end

    # blocks exclusive to person
    if profile.person?
      blocks << FriendsBlock
      blocks << FavoriteEnterprisesBlock
      blocks << MyNetworkBlock
    end

    # blocks exclusive for enterprises
    if profile.enterprise?
      blocks << ProductsBlock
    end

    blocks
  end

end
