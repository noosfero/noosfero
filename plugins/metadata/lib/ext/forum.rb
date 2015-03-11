require_dependency 'forum'

class Forum

  metadata_spec namespace: :og, tags: {
    type: proc{ |p, plugin| plugin.context.params[:og_type] || MetadataPlugin.og_types[:forum] || :forum },
  }

end
