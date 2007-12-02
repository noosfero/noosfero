class Image < ActiveRecord::Base
  belongs_to :owner, :polymorphic => true
  
  has_attachment :content_type => :image, 
                 :storage => :file_system, 
                 :max_size => 500.kilobytes,
                 :resize_to => '320x200>',
                 :thumbnails => { :thumb => '100x100>', :minor => '64x64>' }

  validates_as_attachment
end
