class Thumbnail < ActiveRecord::Base
  has_attachment :storage => :file_system,
    :content_type => :image, :max_size => 5.megabytes
  validates_as_attachment

  before_create { |file| file.filename = Environment.verify_filename(file.filename) }

  postgresql_attachment_fu
end
