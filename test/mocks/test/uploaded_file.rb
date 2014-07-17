require File.expand_path(File.dirname(__FILE__) +  "/../../../app/models/uploaded_file")

class UploadedFile < Article

  has_attachment(attachment_options.merge(:path_prefix => "test/tmp"))

end
