require_dependency 'event'

class Event

  metadata_spec namespace: :og, tags: {
    type: proc{ |p, plugin| plugin.context.params[:og_type] || MetadataPlugin.og_types[:event] || :event },
  }

end
