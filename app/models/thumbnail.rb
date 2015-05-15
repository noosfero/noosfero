class Thumbnail < ApplicationRecord

  attr_accessible :uploaded_data
  # mass assigned by attachment_fu
  attr_accessible :content_type, :filename, :thumbnail_resize_options, :thumbnail, :parent_id

  has_attachment :storage => :file_system,
    :content_type => :image, :max_size => UploadedFile.max_size, processor: 'Rmagick'
  validates_as_attachment

  sanitize_filename

  postgresql_attachment_fu

  protected

  def sanitize_filename filename
    # let accents and other utf8
    # overwrite vendor/plugins/attachment_fu/lib/technoweenie/attachment_fu.rb
    filename
  end

end
