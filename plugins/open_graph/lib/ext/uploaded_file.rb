require_dependency 'uploaded_file'

class UploadedFile

  extend OpenGraphPlugin::AttachStories::ClassMethods
  open_graph_attach_stories only: :add_an_image

end
