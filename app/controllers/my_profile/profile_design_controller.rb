class ProfileDesignController < BoxOrganizerController

  needs_profile

  protect 'edit_profile_design', :profile

  before_filter :protect_uneditable_block, :only => [:save]
  before_filter :protect_fixed_block, :only => [:move_block]
  include CategoriesHelper

  def protect_uneditable_block
    block = boxes_holder.blocks.find(params[:id].gsub(/^block-/, ''))
    if !current_person.is_admin? && !block.editable?
      render_access_denied
    end
  end

  def protect_fixed_block
    return if params[:id].blank?
    block = boxes_holder.blocks.find(params[:id].gsub(/^block-/, ''))
    if block.present? && !current_person.is_admin? && !block.movable?
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

  def update_categories
    @object = params[:id] ? @profile.blocks.find(params[:id]) : Block.new
    render_categories 'block'
  end

end
