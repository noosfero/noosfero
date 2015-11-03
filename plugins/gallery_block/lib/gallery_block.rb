class GalleryBlock < Block

  attr_accessible :gallery_id, :groups_of, :speed, :interval

  settings_items :gallery_id, :type => :integer
  settings_items :groups_of, :type => :integer, :default => 3
  settings_items :speed, :type => :integer, :default => 1000

  settings_items :interval, :type => 'integer', :default => 10

  before_save do |block|
    block.groups_of = block.groups_of.to_i
  end

  def self.description
    _('Gallery block')
  end

  def gallery
    if self.owner.kind_of? Environment
      article = owner.articles.find_by_id(self.gallery_id)
      if article && article.gallery?
        article
      end
    else
      owner.image_galleries.find_by_id(self.gallery_id)
    end
  end

  def images
    gallery ? gallery.images : []
  end

  def content(args={})
    block = self
    proc do
      render :file => 'gallery_block', :locals => { :block => block }
    end
  end

end
