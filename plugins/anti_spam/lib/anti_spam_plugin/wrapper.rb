class AntiSpamPlugin::Wrapper < SimpleDelegator
  include Rakismet::Model

  @@wrappers = []
  cattr_accessor :wrappers

  def self.wrap(object)
    wrapper = wrappers.find { |wrapper| wrapper.wraps?(object) }
    wrapper ? wrapper.new(object) : object
  end

  def self.wraps?(object)
    false
  end

  def self.inherited(child)
    child.rakismet_attrs
    wrappers << child
  end
end

Dir.glob(File.join(AntiSpamPlugin.root_path, 'lib', 'anti_spam_plugin', '*_wrapper.rb')) do |file|
  load(file)
end
