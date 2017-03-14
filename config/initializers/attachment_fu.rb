# WORKAROUND: attachment fu needs Rails application
require 'technoweenie/attachment_fu'
require 'monkey_patches/attachment_fu_validates_attachment/init'
require 'monkey_patches/attachment_fu/init'

Technoweenie::AttachmentFu.mattr_writer :default_processors
Technoweenie::AttachmentFu.default_processors = %w(Rmagick ImageScience MiniMagick Gd2 CoreImage)

