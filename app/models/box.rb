class Box < ActiveRecord::Base
  belongs_to :owner, :polymorphic => true
  acts_as_list :scope => 'owner_id = #{owner_id} and owner_type = \'#{owner_type}\''
  has_many :blocks, :dependent => :destroy, :order => 'position'

  def acceptable_blocks
    to_css_class_name (position == 1) ? acceptable_center_blocks : acceptable_side_blocks
  end

  private

  def acceptable_center_blocks
    %w{
      CommunitiesBlock
      EnterprisesBlock
      FriendsBlock
      LinkListBlock
      MainBlock
      PeopleBlock
    }
  end

  def acceptable_side_blocks
    %w{
      ArticleBlock
      CategoriesBlock
      CommunitiesBlock
      EnterprisesBlock
      EnvironmentStatisticsBlock
      FeaturedProductsBlock
      FeedReaderBlock
      FriendsBlock
      HighlightsBlock
      LinkListBlock
      LocationBlock
      LoginBlock
      MyNetworkBlock
      PeopleBlock
      ProfileImageBlock
      ProfileInfoBlock
      ProfileSearchBlock
      RawHTMLBlock
      RecentDocumentsBlock
      SellersSearchBlock
      SlideshowBlock
      TagsBlock
    }
  end

  def to_css_class_name(blocks)
    blocks.map{ |block| block.underscore.tr('_', '-') }
  end

end
