class Image < ActiveRecord::Base
  belongs_to :owner, :polymorphic => true
  
  has_attachment :content_type => :image, 
                 :storage => :file_system, 
                 :max_size => 500.kilobytes,
                 :resize_to => '320x200>',
                 :thumbnails => { :big      => '150x150',
                                  :thumb    => '100x100',
                                  :portrait => '64x64',
                                  :minor    => '50x50',
                                  :icon     => '20x20!' }

  validates_as_attachment
end
