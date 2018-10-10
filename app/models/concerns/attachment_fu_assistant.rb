module AttachmentFuAssistant

  module ClassMethods
    def attachment_fu_thumbnails
      include AttachmentFuAssistant::InstanceMethods

      before_validation :remove_ext_from_name, on: :create

      before_create do |file|
        (origfname, fname, ext) = file.split_filename
        # ensure there is a fname
        fname = fname || file.filename
        fname, thumb_suffix = fname.split(/(_big|_icon|_minor|_portrait|_thumb)$/) if file.try(:thumbnail?)
        thumb_suffix ||= ''
        # makes filename secure for FS manipulation and URLs
        file.filename = fname.to_slug + thumb_suffix + ext.to_s.to_slug
      end
    end
  end

  module InstanceMethods
    # skip processing with RMagick
    def process_attachment
    end

    def after_process_attachment
      save_to_storage
      @temp_paths.clear
      @saved_attachment = nil
      run_callbacks :after_attachment_saved
      create_thumbnails unless self.thumbnails_processed
    end

    def create_thumbnails
      if thumbnailable?
        self.class.with_image(full_filename) do |img|
          self.width = img.columns
          self.height = img.rows
        end
        self.class.attachment_options[:thumbnails].each do |suffix, size|
          self.create_or_update_thumbnail(self.full_filename, suffix, size)
        end
        self.thumbnails_processed = true
        self.save!
      end
    end

    def public_filename(size=nil)
      force, size = true, nil if size == :uploaded
      if !self.thumbnailable? || self.thumbnails_processed || force
        super size
      else
        self.full_filename.to_s.gsub %r(^#{Regexp.escape(base_path)}), ''
      end
    end

    def remove_ext_from_name
      if self.kind_of?(UploadedFile) && self.name == self.filename
        (origfname, fname, ext) = self.split_filename
        self.name = fname
      end
    end

    # Returns (original_filename, name, extension)
    def split_filename
      self.filename.match(/^(.*)(\.[^.]*)$/).to_a
    end

    def thumbnailable?
        super && (File.extname(temp_path) != '.ico')
    end
  end
end
