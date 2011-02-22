class EnvironmentDesignController < BoxOrganizerController
  
  protect 'edit_environment_design', :environment

  def available_blocks
    @available_blocks ||= [ ArticleBlock, LoginBlock, EnvironmentStatisticsBlock, RecentDocumentsBlock, EnterprisesBlock, CommunitiesBlock, PeopleBlock, SellersSearchBlock, LinkListBlock, FeedReaderBlock, SlideshowBlock, HighlightsBlock, FeaturedProductsBlock, CategoriesBlock, RawHTMLBlock ]
  end

end
