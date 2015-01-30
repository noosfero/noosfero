require_dependency 'article'

class Article

  Metadata = {
    'og:type' => MetadataPlugin.og_types[:article],
    'og:url' => proc{ |a, c| c.og_url_for a.url },
    'og:title' => proc{ |a, c| a.title },
    'og:image' => proc do |a, c|
        result = a.body_images_paths
        result = "#{a.profile.environment.top_url}#{a.profile.image.public_filename}" if a.profile.image if result.blank?
        result = MetadataPlugin.config[:open_graph][:environment_logo] if result.blank?
        result
      end,
    'og:see_also' => [],
    'og:site_name' => proc{ |a, c| a.profile.name },
    'og:updated_time' => proc{ |a, c| a.updated_at.iso8601 },
    'og:locale:locale' => proc{ |a, c| a.environment.default_language },
    'og:locale:alternate' => proc{ |a, c| a.environment.languages - [a.environment.default_language] },
    'twitter:image' => proc{ |a, c| a.body_images_paths },
		'article:expiration_time' => "", # In the future we might want to populate this
		'article:modified_time' => proc{ |a, c| a.updated_at.iso8601 },
		'article:published_time' => proc{ |a, c| a.published_at.iso8601 },
		'article:section' => "", # In the future we might want to populate this
		'article:tag' => proc{ |a, c| a.tags.map &:name },
		'og:description' => proc{ |a, c| ActionView::Base.full_sanitizer.sanitize a.body },
		'og:rich_attachment' => "",
  }



end
