require_dependency 'uploaded_file'
require_relative '../elasticsearch_indexed_model'

class UploadedFile
  def self.control_fields
    {
      :advertise => {},
      :published => {},
      :created_at => {type: 'date'}
    }
  end
  include ElasticsearchIndexedModel
end
