class HighlightsBlock < Block

  attr_accessible :images, :interval, :shuffle, :navigation

  settings_items :images, :type => Array, :default => []
  settings_items :interval, :type => 'integer', :default => 4
  settings_items :shuffle, :type => 'boolean', :default => false
  settings_items :navigation, :type => 'boolean', :default => false

  before_save do |block|
    block.images = block.images.delete_if { |i| i[:image_id].blank? and i[:address].blank? and i[:position].blank? and i[:title].blank? }
    block.images.each do |i|
      i[:image_id] = i[:image_id].to_i
      i[:position] = i[:position].to_i
      if !Noosfero.root.nil? and !i[:address].start_with?(Noosfero.root + '/')
        i[:address] = Noosfero.root + i[:address]
      end
      begin
        file = UploadedFile.find(i[:image_id])
        i[:image_src] = file.public_filename
      rescue
        i[:image_src] = nil
      end
    end
  end

  def self.description
    _('Creates image slideshow')
  end

  def featured_images
    images = get_images
    shuffle ? images.shuffle : images
  end

  def get_images
    images.select do |i|
      !i[:image_src].nil?
    end.sort do |x, y|
      x[:position] <=> y[:position]
    end
  end

  def content(args={})
    block = self
    proc do
      render :file => 'blocks/highlights', :locals => { :block => block }
    end
  end

  def folder_choices
    owner.image_galleries
  end

end
