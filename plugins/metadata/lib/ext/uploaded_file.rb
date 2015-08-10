require_dependency 'uploaded_file'
require_dependency "#{File.dirname __FILE__}/article"

class UploadedFile

  metadata_spec namespace: :og, tags: {
    type: proc do |u, plugin|
      type = if u.image? then :image else :uploaded_file end
      plugin.context.params[:og_type] || MetadataPlugin.og_types[type] || type
    end,
    url: proc do |u, plugin|
      url = u.url.merge! profile: u.profile.identifier, view: true, og_type: plugin.context.params[:og_type]
      plugin.og_url_for url
    end,
    title: proc{ |u, plugin| u.title },
    image: proc{ |u, plugin| "#{u.environment.top_url}#{u.public_filename}" if u.image? },
    description: proc{ |u, plugin| u.abstract || u.title },
  }

end
