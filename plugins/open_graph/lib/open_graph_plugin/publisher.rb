
class OpenGraphPlugin::Publisher

  def self.default
    @default ||= self.new
  end

  def initialize attributes = {}
    attributes.each do |attr, value|
      self.send "#{attr}=", value
    end
  end

  def publish_stories object_data, actor, stories
    stories.each do |story|
      begin
        self.publish_story object_data, actor, story
      rescue => e
        raise unless Rails.env.production?
        ExceptionNotifier.notify_exception e
      end
    end
  end

  def publish_story object_data, actor, story
    OpenGraphPlugin.context = OpenGraphPlugin::Activity.context
    a = OpenGraphPlugin::Activity.new object_data: object_data, actor: actor, story: story
    a.dispatch_publications
    a.save
  end

  protected

end

