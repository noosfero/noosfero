require_dependency 'article'

class Article

  metadata_spec namespace: :og, key_attr: :property, tags: {
    type: MetadataPlugin.og_types[:article] || :article,
    url: proc{ |a, plugin| plugin.og_url_for a.url },
    title: proc{ |a, plugin| "#{a.title} - #{a.profile.name}" },
    image: proc do |a, plugin|
      result = a.body_images_paths
      result = "#{a.profile.environment.top_url}#{a.profile.image.public_filename}" if a.profile.image if result.blank?
      result ||= MetadataPlugin.config[:open_graph][:environment_logo] rescue nil if result.blank?
      result
    end,
    see_also: [],
    site_name: proc{ |a, c| a.profile.name },
    updated_time: proc{ |a, c| a.updated_at.iso8601 },
    'locale:locale' => proc{ |a, c| a.environment.default_language },
    'locale:alternate' => proc{ |a, c| a.environment.languages - [a.environment.default_language] },

    description: proc{ |a, plugin| ActionView::Base.full_sanitizer.sanitize a.body },
    rich_attachment: "",
  }

  metadata_spec namespace: :twitter, key_attr: :name, tags: {
    card: 'summary',
    description: proc do |a, plugin|
      description = a.body.to_s || a.environment.name
      CGI.escapeHTML(plugin.helpers.truncate(plugin.helpers.strip_tags(description), length: 200))
    end,
    title: proc{ |a, plugin| "#{a.title} - #{a.profile.name}" },
    image: proc{ |a, plugin| a.body_images_paths },
  }

  metadata_spec namespace: :article, key_attr: :property, tags: {
    expiration_time: "", # In the future we might want to populate this
    modified_time: proc{ |a, plugin| a.updated_at.iso8601 },
    published_time: proc{ |a, plugin| a.published_at.iso8601 },
    section: "", # In the future we might want to populate this
    tag: proc{ |a, plugin| a.tags.map &:name },
  }

end
