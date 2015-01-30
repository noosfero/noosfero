require_dependency 'profile'

class Profile

  Metadata = {
    'og:type' => MetadataPlugin.og_types[:profile],
    'og:image' => proc{ |p, c| "#{p.environment.top_url}#{p.image.public_filename}" if p.image },
	  'og:title' => proc{ |p, c| p.short_name nil },
    'og:url' => proc do |p, c|
      #force profile identifier for custom domains and fixed host. see og_url_for
      c.og_url_for p.url.merge(profile: p.identifier)
    end,
    'og:description' => proc{ |p, c| p.description },
	  'og:updated_time' => proc{ |p, c| p.updated_at.iso8601 },
	  'place:location:latitude' => proc{ |p, c| p.lat },
	  'place:location:longitude' => proc{ |p, c| p.lng },
    'og:locale:locale' => proc{ |p, c| p.environment.default_language },
    'og:locale:alternate' => proc{ |p, c| p.environment.languages - [p.environment.default_language] },
	  'og:site_name' => "",
	  'og:see_also' => "",
	  'og:rich_attachment' => "",
  }

end
