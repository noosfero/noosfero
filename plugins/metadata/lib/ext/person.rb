require_dependency 'person'
require_dependency "#{File.dirname __FILE__}/profile"

class Person

  metadata_spec namespace: :og, tags: {
    type: proc{ |p, plugin| plugin.context.params[:og_type] || MetadataPlugin.og_types[:person] || :person },
  }

end
