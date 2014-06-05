class EnvironmentDesignController < BoxOrganizerController
  
  protect 'edit_environment_design', :environment

  def available_blocks
    # TODO EnvironmentStatisticsBlock is DEPRECATED and will be removed from
    #      the Noosfero core soon, see ActionItem3045
    @available_blocks ||= [ ArticleBlock, LoginBlock, EnvironmentStatisticsBlock, RecentDocumentsBlock, EnterprisesBlock, CommunitiesBlock, SellersSearchBlock, LinkListBlock, FeedReaderBlock, SlideshowBlock, HighlightsBlock, FeaturedProductsBlock, CategoriesBlock, RawHTMLBlock, TagsBlock ]
    @available_blocks += plugins.dispatch(:extra_blocks, :type => Environment)
  end

end
