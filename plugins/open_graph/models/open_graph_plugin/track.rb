class OpenGraphPlugin::Track < ApplicationRecord

  class_attribute :context
  self.context = :open_graph

  attr_accessible :type, :context, :tracker_id, :tracker, :actor_id, :action,
    :object_type, :object_data_id, :object_data_type, :object_data_url,
    :story, :object_data, :actor

  belongs_to :tracker, class_name: 'Profile'
  belongs_to :actor, class_name: 'Profile'
  belongs_to :object_data, polymorphic: true

  before_validation :set_context

  def self.objects
    []
  end

  def self.association
    @association ||= "open_graph_#{self.name.demodulize.pluralize.underscore}".to_sym
  end

  protected

  def set_context
    self[:context] = self.class.context
  end

  def print_debug msg
    puts msg
    Delayed::Worker.logger.debug msg
  end
  def debug? actor=nil
    OpenGraphPlugin.debug? actor
  end

end

