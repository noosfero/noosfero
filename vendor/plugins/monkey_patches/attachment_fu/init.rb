# Monkey patch to rewrite attachment_fu's logic where no image with parent can
# be thumbnailable.

require_dependency 'technoweenie/attachment_fu'

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

# https://github.com/pothoven/attachment_fu/pull/14
# remove on 3.2.16
Technoweenie::AttachmentFu::InstanceMethods.module_eval do
  # Creates or updates the thumbnail for the current attachment.
  def create_or_update_thumbnail(temp_file, file_name_suffix, *size)
    thumbnailable? || raise(ThumbnailError.new("Can't create a thumbnail if the content type is not an image or there is no parent_id column"))
    find_or_initialize_thumbnail(file_name_suffix).tap do |thumb|
      thumb.temp_paths.unshift temp_file
      attributes = {
        content_type:             content_type,
        filename:                 thumbnail_name_for(file_name_suffix),
        thumbnail_resize_options: size
      }
      attributes.each{ |a, v| thumb.send "#{a}=", v }
      callback_with_args :before_thumbnail_saved, thumb
      thumb.save!
    end
  end

  # Initializes a new thumbnail with the given suffix.
  def find_or_initialize_thumbnail(file_name_suffix)
    attrs = {thumbnail: file_name_suffix.to_s}
    attrs[:parent_id] = id if respond_to? :parent_id
    thumb = thumbnail_class.where(attrs).first
    unless thumb
      thumb = thumbnail_class.new
      attrs.each{ |a, v| thumb[a] = v }
    end
    thumb
  end
end
