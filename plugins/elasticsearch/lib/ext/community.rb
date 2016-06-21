require_dependency 'community'
require_relative '../elasticsearch_indexed_model'

class Community
  def self.control_fields
    {
      :created_at => {type: 'date'}
    }
  end
  include ElasticsearchIndexedModel
end
