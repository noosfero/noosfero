class OpenGraphPlugin::Track < ActiveRecord::Base

  attr_accessible :type, :context, :tracker_id, :tracker, :actor_id, :action,
    :object_type, :object_data, :object_data_id, :object_data_type, :object_data_url

  belongs_to :tracker, class_name: 'Profile'
  belongs_to :actor, class_name: 'Profile'
  belongs_to :object_data, polymorphic: true

  validates_presence_of :context
  before_validation :set_context

  def self.objects
    []
  end

  def self.association
    @association ||= "open_graph_#{self.name.demodulize.pluralize.underscore}".to_sym
  end

  protected

  def set_context
    self.context = OpenGraphPlugin.context
  end

end

