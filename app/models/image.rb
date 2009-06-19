class Image < ActiveRecord::Base
  belongs_to :owner, :polymorphic => true

  def self.max_size
    Image.attachment_options[:max_size]
  end

  has_attachment :content_type => :image, 
                 :storage => :file_system, 
                 :max_size => 500.kilobytes,
                 :resize_to => '320x200>',
                 :thumbnails => { :big      => '150x150',
                                  :thumb    => '100x100',
                                  :portrait => '64x64',
                                  :minor    => '50x50',
                                  :icon     => '20x20!' }

  validates_attachment :size => N_("The file you uploaded was larger than the maximum size of %s") % Image.max_size.to_humanreadable
end
