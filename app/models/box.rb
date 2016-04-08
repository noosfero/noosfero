class Box < ActiveRecord::Base

  acts_as_list scope: -> box { where owner_id: box.owner_id, owner_type: box.owner_type }

  belongs_to :owner, :polymorphic => true
  has_many :blocks, -> { order 'position' }, dependent: :destroy

  attr_accessible :owner

  include Noosfero::Plugin::HotSpot

  scope :with_position, -> { where 'boxes.position > 0' }

  def environment
    owner ? (owner.kind_of?(Environment) ? owner : owner.environment) : nil
  end

  def acceptable_blocks
    blocks_classes = if central? then Box.acceptable_center_blocks + plugins.dispatch(:extra_blocks, :type => owner.class, :position => 1) else Box.acceptable_side_blocks + plugins.dispatch(:extra_blocks, :type => owner.class, :position => [2, 3]) end
    to_css_selector blocks_classes
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
      FansBlock,
      FavoriteEnterprisesBlock,
      FeedReaderBlock,
      HighlightsBlock,
      LinkListBlock,
      LoginBlock,
      MainBlock,
      MyNetworkBlock,
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
      FansBlock,
      FavoriteEnterprisesBlock,
      FeaturedProductsBlock,
      FeedReaderBlock,
      HighlightsBlock,
      LinkListBlock,
      LocationBlock,
      LoginBlock,
      MyNetworkBlock,
      ProductsBlock,
      ProductCategoriesBlock,
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

  def to_css_selector(blocks_classes)
    blocks_classes.map{ |block_class| ".#{block_class.name.to_css_class}" }.join(',')
  end

end
