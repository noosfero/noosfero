require_dependency 'national_region'
require_relative '../elasticsearch_indexed_model'

class NationalRegion
  include ElasticsearchIndexedModel

  def self.control_fields
    []
  end
end
