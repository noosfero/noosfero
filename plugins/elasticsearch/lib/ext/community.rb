require_dependency 'community'
require_relative '../elasticsearch_indexed_model'

class Community
  include ElasticsearchIndexedModel

  def self.control_fields
    []
  end
end
