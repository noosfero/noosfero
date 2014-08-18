class SlideshowBlock < Block

  settings_items :gallery_id, :type => 'integer'
  settings_items :interval, :type => 'integer', :default => 4
  settings_items :shuffle, :type => 'boolean', :default => false
  settings_items :navigation, :type => 'boolean', :default => false
  settings_items :image_size, :type => 'string', :default => 'thumb'

  attr_accessible :gallery_id, :image_size, :interval, :shuffle, :navigation

  def self.description
    _('Slideshow')
  end

  def gallery
    gallery_id ? Gallery.find(:first, :conditions => { :id => gallery_id }) : nil
  end

  def public_filename_for(image)
    check_filename(image, image_size) || check_filename(image, 'thumb')
  end

  def check_filename(image, size)
    filename = image.public_filename(size)
    if File.exists?(File.join(Rails.root.join('public').to_s, filename))
      filename
    else
      nil
    end
  end

  def block_images
    gallery.images.reject {|item| item.folder?}
  end

  def content(args={})
    block = self
    if gallery
      images = block_images
      if shuffle
        images = images.shuffle
      end
      proc do
        render :file => 'blocks/slideshow', :locals => { :block => block, :images => images }
      end
    else
      proc do
        render :file => 'blocks/slideshow', :locals => { :block => block, :images => nil }
      end
    end
  end

  def folder_choices
    owner.image_galleries
  end

end
