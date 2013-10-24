class AntiSpamPlugin::Wrapper < SimpleDelegator
  include Rakismet::Model

  @@wrappers = []

  def self.wrap(object)
    wrapper = @@wrappers.find { |wrapper| wrapper.wraps?(object) }
    wrapper ? wrapper.new(object) : object
  end

  def self.wraps?(object)
    false
  end

  def self.inherited(child)
    @@wrappers << child
  end
end
