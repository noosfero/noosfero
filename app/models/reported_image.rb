class ReportedImage < ApplicationRecord
  include UploadSanitizer

  belongs_to :abuse_report, optional: true

  validates_presence_of :abuse_report

  has_attachment content_type: :image,
                 storage: :file_system,
                 max_size: 5.megabytes,
                 processor: "Rmagick"
end
