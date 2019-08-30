class Box < ApplicationRecord
  acts_as_list scope: [:owner_id, :owner_type]

  belongs_to :owner, polymorphic: true, optional: true
  has_many :blocks, -> { order "position" }, dependent: :destroy
  accepts_nested_attributes_for :blocks, allow_destroy: true

  attr_accessible :owner, :blocks_attributes

  include Noosfero::Plugin::HotSpot

  scope :with_position, -> { where("boxes.position > 0") }
  scope :with_blocks, -> { includes(blocks: :box) }

  def environment
    owner ? (owner.kind_of?(Environment) ? owner : owner.environment) : nil
  end

  def acceptable_blocks
    blocks_classes = if central? then Box.acceptable_center_blocks + plugins.dispatch(:extra_blocks, type: owner.class, position: 1) else Box.acceptable_side_blocks + plugins.dispatch(:extra_blocks, type: owner.class, position: [2, 3]) end
    to_css_selector blocks_classes
  end

  def central?
    position == 1
  end

  def self.acceptable_center_blocks
    [ArticleBlock,
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
     TagsCloudBlock,
     InterestTagsBlock,
     MenuBlock]
  end

  def self.acceptable_side_blocks
    [ArticleBlock,
     BlogArchivesBlock,
     CategoriesBlock,
     CommunitiesBlock,
     DisabledEnterpriseMessageBlock,
     EnterprisesBlock,
     FansBlock,
     FavoriteEnterprisesBlock,
     FeedReaderBlock,
     HighlightsBlock,
     LinkListBlock,
     LocationBlock,
     LoginBlock,
     MyNetworkBlock,
     ProfileImageBlock,
     ProfileInfoBlock,
     ProfileSearchBlock,
     RawHTMLBlock,
     RecentDocumentsBlock,
     SlideshowBlock,
     TagsCloudBlock,
     InterestTagsBlock,
     MenuBlock]
  end

  def blocks_attributes=(attributes)
    attributes.select { |b| b[:id].nil? }.each do |b|
      block = b.delete(:type).constantize.new(b)
      self.blocks << block
    end
    assign_nested_attributes_for_collection_association(:blocks, attributes.reject { |b| b[:id].nil? }.map { |b| b.except(:type) })
  end

  private

    def to_css_selector(blocks_classes)
      blocks_classes.map { |block_class| ".#{block_class.name.to_css_class}" }.join(",")
    end
end
