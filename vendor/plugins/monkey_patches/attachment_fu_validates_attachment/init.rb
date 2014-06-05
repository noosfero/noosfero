# friendlier attachment validations by Tim Lucas
# ref.: http://toolmantim.com/article/2007/12/3/rollin_your_own_attachment_fu_messages_evil_twin_stylee

Technoweenie::AttachmentFu::InstanceMethods.module_eval do
  protected
    def attachment_valid?
      if self.filename.nil?
        errors.add :empty, attachment_validation_options[:empty]
        return
      end
      [:content_type, :size].each do |option|
        if attachment_validation_options[option] && attachment_options[option] && !attachment_options[option].include?(self.send(option))
          errors.add option, attachment_validation_options[option]
        end
      end
    end
end

Technoweenie::AttachmentFu::ClassMethods.module_eval do
  # Options:
  # *  <tt>:empty</tt> - Base error message when no file is uploaded. Default is "No file uploaded"
  # *  <tt>:content_type</tt> - Base error message when the uploaded file is not a valid content type.
  # *  <tt>:size</tt> - Base error message when the uploaded file is not a valid size.
  #
  # Example:
  #   validates_attachment :content_type => "The file you uploaded was not a JPEG, PNG or GIF",
  #                        :size         => "The image you uploaded was larger than the maximum size of 10MB"
  def validates_attachment(options={})
    options[:empty] ||= "No file uploaded"
    class_attribute :attachment_validation_options
    self.attachment_validation_options = options
    validate :attachment_valid?
  end
end
