require_dependency 'environment'

class Environment

  metadata_spec namespace: :og, tags: {
    site_name: proc{ |e, plugin| e.name },
    description: proc{ |e, plugin| e.name },
    url: proc{ |e, plugin| e.top_url },
    'locale:locale' => proc{ |e, plugin| e.default_language },
    'locale:alternate' => proc{ |e, plugin| e.languages - [e.default_language] },
  }

end
