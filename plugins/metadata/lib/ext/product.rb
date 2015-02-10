require_dependency 'product'

class Product

  metadata_spec namespace: :og, tags: {
    type: MetadataPlugin.og_types[:product] || :product,
    url: proc{ |p, plugin| plugin.og_url_for p.url },
    gr_hascurrencyvalue: proc{ |p, plugin| p.price.to_f },
    gr_hascurrency: proc{ |p, plugin| p.environment.currency_unit },
    title: proc{ |a, plugin| "#{p.name} - #{p.profile.name}" },
    description: proc{ |p, plugin| ActionView::Base.full_sanitizer.sanitize p.description },

    image: proc{ |p, plugin| "#{p.environment.top_url}#{p.image.public_filename}" if p.image },
    'image:type' => proc{ |p, plugin| p.image.content_type if p.image },
    'image:height' => proc{ |p, plugin| p.image.height if p.image },
    'image:width' => proc{ |p, plugin| p.image.width if p.image },

    see_also: [],
    site_name: proc{ |p, plugin| plugin.og_url_for p.profile.url },
    updated_time: proc{ |p, plugin| p.updated_at.iso8601 },

    'locale:locale' => proc{ |p, plugin| p.environment.default_language },
    'locale:alternate' => proc{ |p, plugin| p.environment.languages - [p.environment.default_language] if p.environment.languages },
  }

end
