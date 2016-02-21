require_dependency 'article'

class Article

  scope :video_gallery, -> { where "articles.type = 'VideoPlugin::VideoGallery'" }

  #FIXME This should be done via hotspot
  def self.folder_types_with_video
    self.folder_types_without_video << 'VideoPlugin::VideoGallery'
  end

  #FIXME This should be done via hotspot
  class << self
    alias_method_chain :folder_types, :video
  end

  def self.owner_video_galleries(owner)
    conditions = owner.kind_of?(Environment) ?  [] : ["profile_id = ?", owner.id]
    result = Article.video_gallery
      .order('created_at desc')
      .where(conditions)
  end

end






