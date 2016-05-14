module UploadSanitizer
  def self.included(base)
    base.extend(ClassMethods)
  end

  module ClassMethods
    def sanitize_filename
      before_create { |file| file.filename = Environment.verify_filename(file.filename) }
    end
  end
end

ActiveRecord::Base.send :include, UploadSanitizer
