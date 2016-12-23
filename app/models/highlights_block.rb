class HighlightsBlock < Block

  attr_accessible :block_images, :interval, :shuffle, :navigation

  settings_items :block_images, :type => Array, :default => []
  settings_items :interval, :type => 'integer', :default => 4
  settings_items :shuffle, :type => 'boolean', :default => false
  settings_items :navigation, :type => 'boolean', :default => false

  before_save :remove_unused_images

  before_save do |block|
    block.block_images = block.block_images.delete_if { |i| i[:image_id].blank? and i[:address].blank? and i[:position].blank? and i[:title].blank? }
    block.block_images.each do |i|
      i[:image_id] = i[:image_id].to_i
      i[:position] = i[:position].to_i
      if !Noosfero.root.nil? and !i[:address].start_with?(Noosfero.root + '/')
        i[:address] = Noosfero.root + i[:address]
      end
      i[:new_window] = i[:new_window] == '1' ? true : false

      uploaded_file = UploadedFile.find_by(id: i[:image_id])
      i[:image_src] = uploaded_file.public_filename if uploaded_file.present?
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
    block_images.select do |i|
      !i[:image_src].nil?
    end.sort do |x, y|
      x[:position] <=> y[:position]
    end
  end

  def folder_choices
    owner.image_galleries
  end

  def display_api_content_by_default?
    true
  end

  def api_content
    slides = self.block_images
    slides.each do |slide|
      image = self.images.find_by(id: slide[:image_id])
      if image.present?
        slide[:image_src] = image.public_filename
      else
        slide[:image_id] = nil
      end
    end
    { slides: slides }
  end

  def remove_unused_images
    image_ids = self.block_images.map { |slide| slide[:image_id] }
    images.where.not(id: image_ids).destroy_all
  end

end
