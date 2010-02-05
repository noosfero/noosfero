class SlideshowBlock < Block

  settings_items :gallery_id, :type => 'integer'
  settings_items :interval, :type => 'integer', :default => 4
  settings_items :shuffle, :type => 'boolean', :default => false
  settings_items :navigation, :type => 'boolean', :default => false

  def self.description
    _('Slideshow')
  end

  def gallery
    gallery_id ? Folder.find(gallery_id) : nil
  end

  def content
    block = self
    if gallery
      images = gallery.images
      if shuffle
        images = images.shuffle
      end
      lambda do
        render :file => 'blocks/slideshow', :locals => { :block => block, :images => images }
      end
    else
      lambda do
        render :file => 'blocks/slideshow', :locals => { :block => block, :images => nil }
      end
    end
  end

end
