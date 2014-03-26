class AntiSpamPlugin::Wrapper < SimpleDelegator
  include Rakismet::Model

  @@wrappers = [AntiSpamPlugin::CommentWrapper, AntiSpamPlugin::SuggestArticleWrapper]

  def self.wrap(object)
    wrapper = @@wrappers.find { |wrapper| wrapper.wraps?(object) }
    wrapper ? wrapper.new(object) : object
  end

  def self.wraps?(object)
    false
  end

#  FIXME You can't take for granted that the wrappers will be loaded and, therefore,
#  included in the @@wrappers variable.
#  def self.inherited(child)
#    @@wrappers << child
#  end
end
