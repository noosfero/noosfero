require_dependency 'product'

class Product

  Metadata = {
    'og:type' => MetadataPlugin.og_types[:product],
    'og:url' => proc{ |p, c| c.og_url_for p.url },
    'og:gr_hascurrencyvalue' => proc{ |p, c| p.price.to_f },
    'og:gr_hascurrency' => proc{ |p, c| p.environment.currency_unit },
    'og:title' => proc{ |p, c| p.name },
    'og:description' => proc{ |p, c| ActionView::Base.full_sanitizer.sanitize p.description },
    'og:image' => proc{ |p, c| "#{p.environment.top_url}#{p.image.public_filename}" if p.image },
    'og:image:type' => proc{ |p, c| p.image.content_type if p.image },
    'og:image:height' => proc{ |p, c| p.image.height if p.image },
    'og:image:width' => proc{ |p, c| p.image.width if p.image },
    'og:see_also' => [],
    'og:site_name' => proc{ |p, c| c.og_url_for p.profile.url },
    'og:updated_time' => proc{ |p, c| p.updated_at.iso8601 },
    'og:locale:locale' => proc{ |p, c| p.environment.default_language },
    'og:locale:alternate' => proc{ |p, c| p.environment.languages - [p.environment.default_language] },
  }

  protected

end
