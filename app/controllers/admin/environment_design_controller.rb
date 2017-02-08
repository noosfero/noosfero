class EnvironmentDesignController < BoxOrganizerController

  protect 'edit_environment_design', :environment

  def available_blocks
    @available_blocks ||= [ ArticleBlock, LoginBlock, RecentDocumentsBlock, EnterprisesBlock, CommunitiesBlock, LinkListBlock, FeedReaderBlock, SlideshowBlock, HighlightsBlock, CategoriesBlock, RawHTMLBlock, TagsCloudBlock ]
    @available_blocks += plugins.dispatch(:extra_blocks, :type => Environment)
  end

end
