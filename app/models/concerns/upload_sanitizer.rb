module UploadSanitizer
  extend ActiveSupport::Concern

  included do
    before_create { |file| file.filename = Environment.verify_filename(file.filename) }

    def sanitize_filename filename
      # let accents and other utf8, but remotes the extension
      # overwrite vendor/plugins/attachment_fu/lib/technoweenie/attachment_fu.rb
      filename
    end
  end

end
