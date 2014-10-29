require_dependency 'uploaded_file'
require_dependency "#{File.dirname __FILE__}/article"

class UploadedFile

  Metadata = {
    'og:type' => proc do |u, c|
      type = if u.image? then :image else :uploaded_file end
      MetadataPlugin.og_types[type]
    end,
    'og:url' => proc{ |u, c| c.og_url_for u.url.merge(view: true) },
    'og:title' => proc{ |u, c| u.title },
    'og:image' => proc{ |u, c| "#{u.environment.top_url}#{u.public_filename}" if u.image? },
    'og:description' => proc{ |u, c| u.abstract || u.title },
  }

end
