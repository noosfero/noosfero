require_dependency 'community'
require_dependency "#{File.dirname __FILE__}/profile"

class Community

  Metadata = Metadata.merge({
    'og:type' => MetadataPlugin.og_types[:community],
  })

end
