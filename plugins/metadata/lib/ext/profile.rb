require_dependency 'profile'

class Profile

  metadata_spec namespace: :og, tags: {
    type: proc{ |p, plugin| plugin.context.params[:og_type] || MetadataPlugin.og_types[:profile] || :profile },
    image: proc do |p, plugin|
      img = "#{p.environment.top_url}#{p.image.public_filename}".html_safe if p.image
      img ||= MetadataPlugin.config[:open_graph][:environment_logo].html_safe rescue nil if img.blank?
      img
    end,
    title: proc{ |p, plugin| if p.nickname.present? then p.nickname else p.name end },
    url: proc{ |p, plugin| plugin.og_url_for plugin.og_profile_url(p) },
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
