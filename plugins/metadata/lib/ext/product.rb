require_dependency 'product'

class Product

  metadata_spec namespace: :og, tags: {
    type: proc{ |p, plugin| plugin.context.params[:og_type] || MetadataPlugin.og_types[:product] || :product },
    url: proc do |p, plugin|
      url = p.url.merge! profile: p.profile.identifier, og_type: plugin.context.params[:og_type]
      plugin.og_url_for url
    end,
    gr_hascurrencyvalue: proc{ |p, plugin| p.price.to_f },
    gr_hascurrency: proc{ |p, plugin| p.environment.currency_unit },
    title: proc{ |p, plugin| "#{p.name} - #{p.profile.name}" if p },
    description: proc{ |p, plugin| ActionView::Base.full_sanitizer.sanitize p.description },

    image: proc do |p, plugin|
      img = "#{p.environment.top_url}#{p.image.public_filename}".html_safe if p.image
      img = "#{p.environment.top_url}#{p.profile.image.public_filename}".html_safe if img.blank? and p.profile.image
      img ||= MetadataPlugin.config[:open_graph][:environment_logo] rescue nil if img.blank?
      img
    end,
    'image:type' => proc{ |p, plugin| p.image.content_type if p.image },
    'image:height' => proc{ |p, plugin| p.image.height if p.image },
    'image:width' => proc{ |p, plugin| p.image.width if p.image },

    see_also: [],
    site_name: proc{ |p, plugin| plugin.og_url_for p.profile.url },
    updated_time: proc{ |p, plugin| p.updated_at.iso8601 if p.updated_at },

    'locale:locale' => proc{ |p, plugin| p.environment.default_language },
    'locale:alternate' => proc{ |p, plugin| p.environment.languages - [p.environment.default_language] if p.environment.languages },
  }

end
