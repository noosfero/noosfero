class Box < ActiveRecord::Base
  belongs_to :owner, :polymorphic => true
  acts_as_list :scope => 'owner_id = #{owner_id} and owner_type = \'#{owner_type}\''
  has_many :blocks, :dependent => :destroy, :order => 'position'

  def environment
    owner ? (owner.kind_of?(Environment) ? owner : owner.environment) : nil
  end

  def acceptable_blocks
    to_css_class_name central?  ? Box.acceptable_center_blocks : Box.acceptable_side_blocks
  end

  def central?
    position == 1
  end

  def self.acceptable_center_blocks
    [ ArticleBlock,
      BlogArchivesBlock,
      CategoriesBlock,
      CommunitiesBlock,
      EnterprisesBlock,
      EnvironmentStatisticsBlock,
      FansBlock,
      FavoriteEnterprisesBlock,
      FeedReaderBlock,
      FriendsBlock,
      HighlightsBlock,
      LinkListBlock,
      LoginBlock,
      MainBlock,
      MembersBlock,
      MyNetworkBlock,
      PeopleBlock,
      ProfileImageBlock,
      RawHTMLBlock,
      RecentDocumentsBlock,
      SellersSearchBlock,
      TagsBlock ]
  end

  def self.acceptable_side_blocks
    [ ArticleBlock,
      BlogArchivesBlock,
      CategoriesBlock,
      CommunitiesBlock,
      DisabledEnterpriseMessageBlock,
      EnterprisesBlock,
      EnvironmentStatisticsBlock,
      FansBlock,
      FavoriteEnterprisesBlock,
      FeaturedProductsBlock,
      FeedReaderBlock,
      FriendsBlock,
      HighlightsBlock,
      LinkListBlock,
      LocationBlock,
      LoginBlock,
      MembersBlock,
      MyNetworkBlock,
      PeopleBlock,
      ProductsBlock,
      ProfileImageBlock,
      ProfileInfoBlock,
      ProfileSearchBlock,
      RawHTMLBlock,
      RecentDocumentsBlock,
      SellersSearchBlock,
      SlideshowBlock,
      TagsBlock
    ]
  end

  private

  def to_css_class_name(blocks)
    blocks.map{ |block| block.to_s.underscore.tr('_', '-') }
  end

end
