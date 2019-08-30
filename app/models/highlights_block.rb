class HighlightsBlock < Block
  attr_accessible :block_images, :interval, :shuffle, :navigation

  settings_items :block_images, type: Array, default: []
  settings_items :interval, type: "integer", default: 4
  settings_items :shuffle, type: "boolean", default: false
  settings_items :navigation, type: "boolean", default: false

  before_save :remove_unused_images

  before_save do |block|
    block.block_images = block.block_images.delete_if { |i| i[:image_id].blank? && i[:address].blank? && i[:position].blank? && i[:title].blank? }

    block.block_images.each do |i|
      i[:image_id] = i[:image_id].to_i
      i[:position] = i[:position].to_i

      if !Noosfero.root.nil? && !i[:address].start_with?(Noosfero.root + "/")
        i[:address] = Noosfero.root + i[:address]
      end

      i[:new_window] = i[:new_window] == "1" ? true : false
      uploaded_file = UploadedFile.find_by(id: i[:image_id])
      i[:image_src] = uploaded_file.public_filename if uploaded_file.present?
    end
  end

  after_save do |block|
    existing_images = block.block_images.map { |i| i[:image_id] }
    update_image = false
    self.images.select { |i| !existing_images.include?(i.id) }.map do |image|
      temp_image = block.block_images.detect { |i| !i.image_id || i.image_id.to_s === "0" }
      next if temp_image.nil?

      temp_image.image_id = image.id
      temp_image.address = self.full_image_path(image)
      temp_image.image_src = image.public_filename
      update_image = true
    end
    self.save if update_image
  end

  def full_image_path(image)
    self.owner.hostname.blank? ? "/#{self.owner.identifier}#{image.public_filename}" : "/#{image.public_filename}"
  end

  def self.description
    _("Creates image slideshow")
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

  def slides=(values)
    self.block_images = values
  end

  def api_content(params = {})
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

  def api_content=(params)
    super
    self.slides = params[:slides]
    self.interval = params[:interval]
  end

  def remove_unused_images
    image_ids = self.block_images.map { |slide| slide[:image_id] }
    images.where.not(id: image_ids).destroy_all
  end
end
