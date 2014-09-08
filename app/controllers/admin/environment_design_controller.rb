class EnvironmentDesignController < BoxOrganizerController
  
  protect 'edit_environment_design', :environment

  def available_blocks
    @available_blocks ||= [ ArticleBlock, LoginBlock, RecentDocumentsBlock, EnterprisesBlock, CommunitiesBlock, SellersSearchBlock, LinkListBlock, FeedReaderBlock, SlideshowBlock, HighlightsBlock, FeaturedProductsBlock, CategoriesBlock, RawHTMLBlock, TagsBlock ]
    @available_blocks += plugins.dispatch(:extra_blocks, :type => Environment)
  end

end
