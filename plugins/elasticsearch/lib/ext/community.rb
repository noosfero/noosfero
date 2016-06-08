require_dependency 'community'
require_relative '../elasticsearch_indexed_model'

class Community
  def self.control_fields
    []
  end
  include ElasticsearchIndexedModel
end
