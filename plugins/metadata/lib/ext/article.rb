require_dependency "article"

class Article
  metadata_spec namespace: :og, key_attr: :property, tags: {
    type: proc do |a, plugin|
      plugin.context.params[:og_type] || MetadataPlugin.og_types[:article] || :article
    end,
    url: proc do |a, plugin|
      url = a.url.merge! profile: a.profile.identifier, og_type: plugin.context.params[:og_type]
      plugin.og_url_for url
    end,
    title: proc { |a, plugin| "#{a.title} - #{a.profile.name}" },
    image: proc do |a, plugin|
      img = a.body_images_paths.map! &:html_safe
      img = "#{a.profile.environment.top_url}#{a.profile.image.public_filename}".html_safe if a.profile.image if img.blank?
      img ||= MetadataPlugin.config[:open_graph][:environment_logo].html_safe rescue nil if img.blank?
      img
    end,
    see_also: [],
    site_name: proc { |a, c| a.profile.name },
    updated_time: proc { |a, c| a.updated_at.iso8601 },
    "locale:locale" => proc { |a, c| a.language || a.environment.default_language },
    "locale:alternate" => proc { |a, c| a.alternate_languages },

    description: proc { |a, plugin| ActionView::Base.full_sanitizer.sanitize a.lead },
    rich_attachment: "",
  }

  metadata_spec namespace: :twitter, key_attr: :name, tags: {
    card: "summary",
    description: proc do |a, plugin|
      description = a.lead.to_s || a.environment.name
      plugin.helpers.truncate plugin.helpers.strip_tags(description), length: 200
    end,
    title: proc { |a, plugin| "#{a.title} - #{a.profile.name}" },
    image: proc { |a, plugin| a.body_images_paths.map! &:html_safe },
  }

  metadata_spec namespace: :article, key_attr: :property, tags: {
    expiration_time: "", # In the future we might want to populate this
    modified_time: proc { |a, plugin| a.updated_at.iso8601 },
    published_time: proc { |a, plugin| a.published_at.iso8601 },
    section: "", # In the future we might want to populate this
    tag: proc { |a, plugin| a.tags.map &:name },
  }
end
