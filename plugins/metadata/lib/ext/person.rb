require_dependency 'person'
require_dependency "#{File.dirname __FILE__}/profile"

class Person

  Metadata = Metadata.merge({
    'og:type' => MetadataPlugin.og_types[:person],
  })

end
