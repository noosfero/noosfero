require_dependency 'profile'

class Profile

  metadata_spec namespace: :og, tags: {
    type: MetadataPlugin.og_types[:profile] || :profile,
    image: proc{ |p, plugin| "#{p.environment.top_url}#{p.image.public_filename}" if p.image },
    title: proc{ |p, plugin| p.nickname || p.name },
    url: proc do |p, plugin|
      #force profile identifier for custom domains and fixed host. see og_url_for
      plugin.og_url_for p.url.merge(profile: p.identifier)
    end,
    description: proc{ |p, plugin| p.description },
	  updated_time: proc{ |p, plugin| p.updated_at.iso8601 },
    'locale:locale' => proc{ |p, plugin| p.environment.default_language },
    'locale:alternate' => proc{ |p, plugin| p.environment.languages - [p.environment.default_language] if p.environment.languages },
	  site_name: "",
	  see_also: "",
	  rich_attachment: "",
  }

  metadata_spec namespace: 'place:location', tags: {
	  latitude: proc{ |p, plugin| p.lat },
	  longitude: proc{ |p, plugin| p.lng },
  }

  metadata_spec namespace: :twitter, key_attr: :name, tags: {
    card: 'summary',
    title: proc{ |p, plugin| p.name },
    description: proc{ |p, plugin| p.description },
  }

end
