require_dependency 'profile'
# hate to wrte this, but without Noosfero::Plugin::Settings is loaded instead
require 'open_graph_plugin/settings'

# attr_accessible must be defined on subclasses
Profile.descendants.each do |subclass|
  subclass.class_eval do
    attr_accessible :open_graph_settings

    OpenGraphPlugin::TrackConfig::Types.each do |track, klass|
      klass = "OpenGraphPlugin::#{klass}".constantize
      attributes = "#{klass.association}_attributes"
      profile_ids = "open_graph_#{track}_profiles_ids"

      attr_accessible attributes
      attr_accessible profile_ids
    end
  end
end

class Profile

  def open_graph_settings attrs = {}
    @open_graph_settings ||= OpenGraphPlugin::Settings.new self, attrs
    attrs.each{ |a, v| @open_graph_settings.send "#{a}=", v }
    @open_graph_settings
  end
  alias_method :open_graph_settings=, :open_graph_settings

  has_many :open_graph_tracks, class_name: 'OpenGraphPlugin::Track', source: :tracker_id, foreign_key: :tracker_id

  has_many :open_graph_activities, class_name: 'OpenGraphPlugin::Activity', source: :tracker_id, foreign_key: :tracker_id

  has_many :open_graph_track_configs, class_name: 'OpenGraphPlugin::TrackConfig', source: :tracker_id, foreign_key: :tracker_id
  OpenGraphPlugin::TrackConfig::Types.each do |track, klass|
    klass = "OpenGraphPlugin::#{klass}".constantize
    association = klass.association
    profile_ids = "open_graph_#{track}_profiles_ids"

    has_many association, class_name: klass.name, foreign_key: :tracker_id
    accepts_nested_attributes_for association, allow_destroy: true, reject_if: :open_graph_reject_empty_object_type

    define_method "#{profile_ids}=" do |ids|
      cids = self.send(association).order('created_at ASC').map(&:object_data_id)
      nids = if ids.is_a? Array then ids else ids.split ',' end
      nids = nids.map(&:to_i)
      Profile.where(id: nids-cids).each{ |profile| self.send(association).create! type: klass.name, object_data: profile }
      self.send(association).each{ |c| c.destroy unless c.object_data_id.in? nids }
    end

  end

  define_method :open_graph_reject_empty_object_type do |attributes|
    exists = attributes[:id].present?
    empty = attributes[:object_type].empty?
    attributes.merge! _destroy: 1 if exists and empty
    return (!exists and empty)
  end
end
