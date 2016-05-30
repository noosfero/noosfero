require_dependency 'gallery'
require_relative '../elasticsearch_indexed_model'

class Gallery
  include ElasticsearchIndexedModel

  def self.control_fields
    [
      :advertise,
      :published,
    ]
  end
end
