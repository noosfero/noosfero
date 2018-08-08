
if defined?(Rails::Engine)
  # Rails >= 3
  class Engine < Rails::Engine
    # Mimic old vendored plugin behavior, attachment_fu/lib is autoloaded.
    config.autoload_paths << File.expand_path("..", __FILE__)

    initializer "attachment_fu" do
      require 'geometry'

      ActiveRecord::Base.send(:extend, Technoweenie::AttachmentFu::ActMethods)
      Technoweenie::AttachmentFu.tempfile_path = ATTACHMENT_FU_TEMPFILE_PATH if Object.const_defined?(:ATTACHMENT_FU_TEMPFILE_PATH)
      FileUtils.mkdir_p Technoweenie::AttachmentFu.tempfile_path
    end
  end
else
  # Rails <= 2
  require 'geometry'

  ActiveSupport::Dependencies.autoload_paths << File.expand_path("..", __FILE__)

  ActiveRecord::Base.send(:extend, Technoweenie::AttachmentFu::ActMethods)
  Technoweenie::AttachmentFu.tempfile_path = ATTACHMENT_FU_TEMPFILE_PATH if Object.const_defined?(:ATTACHMENT_FU_TEMPFILE_PATH)
  FileUtils.mkdir_p Technoweenie::AttachmentFu.tempfile_path

  $:.unshift(File.expand_path("../vendor", __FILE__))
end
