class Image < ActiveRecord::Base

  attr_accessible :uploaded_data, :label, :remove_image
  attr_accessor :remove_image

  def self.max_size
    Image.attachment_options[:max_size]
  end

  sanitize_filename

  has_attachment :content_type => :image,
                 :storage => :file_system,
                 :path_prefix => 'public/image_uploads',
                 :resize_to => '800x600>',
                 :thumbnails => { :big      => '150x150',
                                  :thumb    => '100x100',
                                  :portrait => '64x64',
                                  :minor    => '50x50>',
                                  :icon     => '20x20!' },
                 :max_size => 5.megabytes, # remember to update validate message below
                 processor: 'Rmagick'

  validates_attachment :size => N_("{fn} of uploaded file was larger than the maximum size of 5.0 MB").fix_i18n

  delay_attachment_fu_thumbnails

  postgresql_attachment_fu

  def current_data
    File.file?(full_filename) ? File.read(full_filename) : nil
  end

end
