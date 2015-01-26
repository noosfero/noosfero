class ProfileDesignController < BoxOrganizerController

  needs_profile

  protect 'edit_profile_design', :profile

  before_filter :protect_fixed_block, :only => [:save, :move_block]

  def protect_fixed_block
    block = boxes_holder.blocks.find(params[:id].gsub(/^block-/, ''))
    if block.fixed && !current_person.is_admin?
      render_access_denied
    end
  end

  def available_blocks
    blocks = [ ArticleBlock, TagsBlock, RecentDocumentsBlock, ProfileInfoBlock, LinkListBlock, MyNetworkBlock, FeedReaderBlock, ProfileImageBlock, LocationBlock, SlideshowBlock, ProfileSearchBlock, HighlightsBlock ]

    blocks += plugins.dispatch(:extra_blocks)

    # blocks exclusive to people
    if profile.person?
      blocks << FavoriteEnterprisesBlock
      blocks << CommunitiesBlock
      blocks << EnterprisesBlock
      blocks += plugins.dispatch(:extra_blocks, :type => Person)
    end

    # blocks exclusive to communities
    if profile.community?
      blocks += plugins.dispatch(:extra_blocks, :type => Community)
    end

    # blocks exclusive for enterprises
    if profile.enterprise?
      blocks << DisabledEnterpriseMessageBlock
      blocks << HighlightsBlock
      blocks << ProductCategoriesBlock
      blocks << FeaturedProductsBlock
      blocks << FansBlock
      blocks += plugins.dispatch(:extra_blocks, :type => Enterprise)
    end

    # product block exclusive for enterprises in environments that permits it
    if profile.enterprise? && profile.environment.enabled?('products_for_enterprises')
      blocks << ProductsBlock
    end

    # block exclusive to profiles that have blog
    if profile.has_blog?
      blocks << BlogArchivesBlock
    end

    if user.is_admin?(profile.environment)
      blocks << RawHTMLBlock
    end

    blocks
  end

end
