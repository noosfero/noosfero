module DelayedAttachmentFu

  module ClassMethods
    def delay_attachment_fu_thumbnails
      include DelayedAttachmentFu::InstanceMethods
      after_create do |file|
        if file.thumbnailable?
          Delayed::Job.enqueue CreateThumbnailsJob.new(file.class.name, file.id)
        end
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
      callback :after_attachment_saved
    end

    def create_thumbnails
      if thumbnailable?
        self.class.with_image(full_filename) do |img|
          self.width = img.columns
          self.height = img.rows
          self.save!
        end
        self.class.attachment_options[:thumbnails].each do |suffix, size|
          self.create_or_update_thumbnail(self.full_filename, suffix, size)
        end
        self.update_attributes!(:thumbnails_processed => true)
      end
    end

    def public_filename(size=nil)
      if self.thumbnails_processed
        super(size)
      else
        size ||= 'thumb'
        '/images/icons-app/image-loading-%s.png' % size
      end
    end


  end
end

ActiveRecord::Base.send(:extend, DelayedAttachmentFu::ClassMethods)
