require_dependency 'community'
require_dependency "#{File.dirname __FILE__}/profile"

class Community

  metadata_spec namespace: :og, tags: {
    type: proc{ |c, plugin| plugin.context.params[:og_type] || MetadataPlugin.og_types[:community] || :community },
  }

end
