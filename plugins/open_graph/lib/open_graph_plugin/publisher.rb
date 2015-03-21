
class OpenGraphPlugin::Publisher

  attr_accessor :actions
  attr_accessor :objects

  def self.default
    @default ||= self.new
  end

  def initialize attributes = {}
    # defaults
    self.actions = OpenGraphPlugin::Stories::DefaultActions
    self.objects = OpenGraphPlugin::Stories::DefaultObjects

    attributes.each do |attr, value|
      self.send "#{attr}=", value
    end
  end

  def publish actor, story_defs, object_data_url
    raise 'abstract method called'
  end

  def publish_stories object_data, actor, stories
    stories.each do |story|
      begin
        self.publish_story object_data, actor, story
      rescue => e
        ExceptionNotifier.notify_exception e
      end
    end
  end

  def update_delay
    1.day
  end

  # only publish recent objects to avoid multiple publications
  def recent_publish? actor, object_type, object_data_url
    activity_params = {actor_id: actor.id, object_type: object_type, object_data_url: object_data_url}
    activity = OpenGraphPlugin::Activity.where(activity_params).first
    activity.present? and activity.created_at <= self.update_delay.from_now
  end

  def publish_story object_data, actor, story
    OpenGraphPlugin.context = self.context
    defs = OpenGraphPlugin::Stories::Definitions[story]
    passive = defs[:passive]

    print_debug "open_graph: publish_story #{story}" if debug? actor
    match_criteria = if (ret = self.call defs[:criteria], object_data, actor).nil? then true else ret end
    return unless match_criteria
    print_debug "open_graph: #{story} match criteria" if debug? actor
    match_condition = if (ret = self.call defs[:publish_if], object_data, actor).nil? then true else ret end
    return unless match_condition
    print_debug "open_graph: #{story} match publish_if" if debug? actor

    actors = self.story_trackers defs, actor, object_data
    return if actors.blank?
    print_debug "open_graph: #{story} has enabled trackers" if debug? actor

    if publish = defs[:publish]
      begin
        instance_exec actor, object_data, &publish
      rescue => e
        print_debug "open_graph: can't publish story: #{e.message}" if debug? actor
        ExceptionNotifier.notify_exception e
      end
    else
      # force profile identifier for custom domains and fixed host. see og_url_for
      object_profile = self.call(story_defs[:object_profile], object_data) || object_data.profile rescue nil
      extra_params = if object_profile then {profile: object_profile.identifier} else {} end

      custom_object_data_url = self.call defs[:object_data_url], object_data, actor
      object_data_url = if passive then self.passive_url_for object_data, custom_object_data_url, defs, extra_params else self.url_for object_data, custom_object_data_url, extra_params end

      actors.each do |actor|
        print_debug "open_graph: start publishing" if debug? actor
        begin
          self.publish actor, defs, object_data_url
        rescue => e
          print_debug "open_graph: can't publish story: #{e.message}" if debug? actor
          ExceptionNotifier.notify_exception e
        end
      end
    end
  end

  def story_trackers story_defs, actor, object_data
    passive = story_defs[:passive]
    trackers = []

    track_configs = Array(story_defs[:track_config]).compact.map(&:constantize)
    return if track_configs.empty?
    print_debug "open_graph: using configs: #{track_configs.map(&:name).inspect}" if debug? actor

    if passive
      object_profile = self.call(story_defs[:object_profile], object_data) || object_data.profile rescue nil
      return unless object_profile

      track_configs.each do |c|
        trackers.concat c.trackers_to_profile(object_profile)
      end.flatten

      trackers.select! do |t|
        track_configs.any?{ |c| c.enabled? self.context, t }
      end
    else #active
      object_actor = self.call(story_defs[:object_actor], object_data) || object_data.profile rescue nil
      return unless object_actor and object_actor.person?
      custom_actor = self.call(story_defs[:custom_actor], object_data)
      actor = custom_actor if custom_actor

      match_track = track_configs.any? do |c|
        c.enabled?(self.context, actor) and
          actor.send("open_graph_#{c.track_name}_track_configs").where(object_type: story_defs[:object_type]).first
      end
      trackers << actor if match_track
    end

    trackers
  end

  protected

  include MetadataPlugin::UrlHelper

  def register_publish attributes
    OpenGraphPlugin::Activity.create! attributes
  end

  # Call don't ask: move to a og_url method inside object
  def url_for object, custom_url=nil, extra_params={}
    return custom_url if custom_url.is_a? String
    url = custom_url || if object.is_a? Profile then og_profile_url object else object.url end
    # for profile when custom domain is used
    url.merge! profile: object.profile.identifier if object.respond_to? :profile
    url.merge! extra_params
    self.og_url_for url
  end

  def passive_url_for object, custom_url, story_defs, extra_params={}
    object_type = story_defs[:object_type]
    extra_params.merge! og_type: MetadataPlugin.og_types[object_type]
    self.url_for object, custom_url, extra_params
  end

  def call p, *args
    p and instance_exec *args, &p
  end

  def context
    :open_graph
  end

  def print_debug msg
    puts msg
    Delayed::Worker.logger.debug msg
  end
  def debug? actor=nil
    !Rails.env.production?
  end

end

