# This is a log of activities, unlike ActivityTrack that is a configuration
class OpenGraphPlugin::Activity < OpenGraphPlugin::Track

  Defs = OpenGraphPlugin::Stories::Definitions

  UpdateDelay = 1.day

  class_attribute :actions, :objects
  self.actions = OpenGraphPlugin::Stories::DefaultActions
  self.objects = OpenGraphPlugin::Stories::DefaultObjects

  validates_presence_of :action
  validates_presence_of :object_type

  # subclass this to define (e.g. FbAppPlugin::Activity)
  def scrape
    raise NotImplementedError
  end
  def publish! actor = self.actor
    self.published_at = Time.now
    print_debug "open_graph: published with success" if debug? actor
  end

  def defs
    @defs ||= Defs[self.story.to_sym]
  end
  def object_profile
    @object_profile ||= self.call(self.defs[:object_profile], self.object_data) || self.object_data.profile rescue nil
  end
  def track_configs
    @track_configs ||= Array(self.defs[:track_config]).compact.map(&:constantize)
  end
  def match_criteria?
    if (ret = self.call self.defs[:criteria], self.object_data, self.actor).nil? then true else ret end
  end
  def match_publish_if?
    if (ret = self.call self.defs[:publish_if], self.object_data, self.actor).nil? then true else ret end
  end
  def custom_object_data_url
    @custom_object_data_url ||= self.call defs[:object_data_url], self.object_data, self.actor
  end
  def object_actor
    @object_actor ||= self.call(self.defs[:object_actor], self.object_data) || self.object_data.profile rescue nil
  end
  def custom_actor
    @custom_actor ||= self.call self.defs[:custom_actor], self.object_data
  end

  def set_object_data_url
    # force profile identifier for custom domains and fixed host. see og_url_for
    extra_params = if self.object_profile then {profile: self.object_profile.identifier} else {} end

    self.object_data_url = if self.defs[:passive] then self.passive_url_for self.object_data, self.custom_object_data_url, self.defs, extra_params else self.url_for self.object_data, self.custom_object_data_url, extra_params end
  end

  def dispatch_publications
    print_debug "open_graph: dispatch_publications of #{story}" if debug? self.actor

    return unless self.match_criteria?
    print_debug "open_graph: #{story} match criteria" if debug? self.actor
    return unless self.match_publish_if?
    print_debug "open_graph: #{story} match publish_if" if debug? self.actor
    return unless (actors = self.trackers).present?
    print_debug "open_graph: #{story} has enabled trackers" if debug? self.actor

    self.set_object_data_url
    self.action = self.class.actions[self.defs[:action]]
    self.object_type = self.class.objects[self.defs[:object_type]]

    print_debug "open_graph: start publishing" if debug? actor
    unless (publish = self.defs[:publish]).present?
      actors.each do |actor|
        begin
          self.publish! actor
        rescue => e
          print_debug "open_graph: can't publish story: #{e.message}" if debug? actor
          raise unless Rails.env.production?
          ExceptionNotifier.notify_exception e
        end
      end
    else # custom publish proc
      begin
        instance_exec self.actor, self.object_data, &publish
      rescue => e
        print_debug "open_graph: can't publish story: #{e.message}" if debug? self.actor
        raise unless Rails.env.production?
        ExceptionNotifier.notify_exception e
      end
    end
  end

  def trackers
    @trackers ||= begin
      return if self.track_configs.empty?
      trackers = []

      print_debug "open_graph: using configs: #{self.track_configs.map(&:name).inspect}" if debug? self.actor

      if self.defs[:passive]
        return unless self.object_profile

        self.track_configs.each do |c|
          trackers.concat c.trackers_to_profile(self.object_profile)
        end.flatten

        trackers.select! do |t|
          self.track_configs.any?{ |c| c.enabled? self.context, t }
        end
      else #active
        return unless self.object_actor and self.object_actor.person?
        actor = self.custom_actor || self.actor

        match_track = self.track_configs.any? do |c|
          c.enabled?(self.context, actor) and
            actor.send("open_graph_#{c.track_name}_track_configs").where(object_type: self.defs[:object_type]).first
        end
        trackers << actor if match_track
      end

      trackers
    end
  end

  protected

  include OpenGraphPlugin::UrlHelper

  def update_delay
    UpdateDelay
  end

  # only publish recent objects to avoid multiple publications
  def recent_publish? actor, object_type, object_data_url
    activity_params = {actor_id: actor.id, object_type: object_type, object_data_url: object_data_url}
    activity = OpenGraphPlugin::Activity.where(activity_params).first
    activity.present? and activity.created_at <= self.update_delay.from_now
  end

  def call p, *args
    p and instance_exec *args, &p
  end

end
