require_dependency 'environment'

class Environment

  metadata_spec tags: {
    description: proc{ |e, plugin| e.name },
  }

  metadata_spec namespace: :og, tags: {
    type: proc{ |e, plugin| plugin.context.params[:og_type] || 'website' },
    title: proc{ |e, plugin| e.name },
    site_name: proc{ |e, plugin| e.name },
    description: proc{ |e, plugin| e.name },
    url: proc{ |e, plugin| e.top_url },
    'locale:locale' => proc{ |e, plugin| e.default_language },
    'locale:alternate' => proc{ |e, plugin| if e.default_language then e.languages - [e.default_language] else e.languages end },
  }

  metadata_spec namespace: :twitter, key_attr: :name, tags: {
    card: 'summary',
    title: proc{ |e, plugin| e.name },
    description: proc{ |e, plugin| e.name },
  }

end
