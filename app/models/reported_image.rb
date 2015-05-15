class ReportedImage < ApplicationRecord
  belongs_to :abuse_report

  validates_presence_of :abuse_report

  has_attachment :content_type => :image,
    :storage     => :file_system,
    :max_size => 5.megabytes,
    processor: 'Rmagick'

  protected

  def sanitize_filename filename
    # let accents and other utf8
    # overwrite vendor/plugins/attachment_fu/lib/technoweenie/attachment_fu.rb
    filename
  end

end
