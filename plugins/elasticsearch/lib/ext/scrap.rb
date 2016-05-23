require_dependency 'scrap'
require_relative '../elasticsearch_indexed_model'

class Scrap
  include ElasticsearchIndexedModel

  def self.control_fields
    [
      :advertise,
      :published,
    ]
  end
end
