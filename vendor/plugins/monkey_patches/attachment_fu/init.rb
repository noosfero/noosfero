# Monkey patch to rewrite attachment_fu's logic where no image with parent can
# be thumbnailable.

require_dependency 'technoweenie/attachment_fu'

ActionDispatch::Reloader.to_prepare do
  Technoweenie::AttachmentFu::InstanceMethods.module_eval do
    def thumbnailable?
      image? && !is_thumbnail?
    end

    def is_thumbnail?
      (thumbnail_class == self.class) && !(respond_to?(:parent_id) && parent_id.nil?)
    end
  end

  # Monkey patch to rewrite attachment_fu's logic where no image with parent can
  # be thumbnailable and supposition that full_filename will return a String
  # while it might return Pathname.
  Technoweenie::AttachmentFu::Backends::FileSystemBackend.module_eval do
    def attachment_path_id
      (is_thumbnail? && respond_to?(:parent_id)) ? parent_id : id
    end

    def public_filename(thumbnail = nil)
      full_filename(thumbnail).to_s.gsub %r(^#{Regexp.escape(base_path)}), ''
    end
  end
end
