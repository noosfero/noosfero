require_dependency 'community'
require_dependency "#{File.dirname __FILE__}/profile"

class Community

  metadata_spec namespace: :og, tags: {
    type: MetadataPlugin.og_types[:community] || :community,
  }

end
