require_dependency 'uploaded_file'
require_relative '../elasticsearch_indexed_model'

class UploadedFile
  include ElasticsearchIndexedModel

  def self.control_fields
    [
      :advertise,
      :published,
    ]
  end
end
