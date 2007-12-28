class Thumbnail < ActiveRecord::Base
  has_attachment :storage => :file_system,
    :content_type => :image
  validates_as_attachment
end
