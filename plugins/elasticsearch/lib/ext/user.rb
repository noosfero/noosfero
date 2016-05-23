require_dependency 'user'
require_relative '../elasticsearch_indexed_model'

class User
  include ElasticsearchIndexedModel

  def self.control_fields
    []
  end
end
