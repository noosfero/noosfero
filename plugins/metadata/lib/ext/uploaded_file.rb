require_dependency 'uploaded_file'
require_dependency "#{File.dirname __FILE__}/article"

class UploadedFile

  metadata_spec namespace: :og, tags: {
    type: proc do |u, plugin|
      type = if u.image? then :image else :uploaded_file end
      MetadataPlugin.og_types[type] || type
    end,
    url: proc{ |u, plugin| plugin.og_url_for u.url.merge(view: true) },
    title: proc{ |u, plugin| u.title },
    image: proc{ |u, plugin| "#{u.environment.top_url}#{u.public_filename}" if u.image? },
    description: proc{ |u, plugin| u.abstract || u.title },
  }

end
