require_dependency 'comment'
require_relative '../elasticsearch_indexed_model'

class Comment
  include ElasticsearchIndexedModel

  def self.control_fields
    []
  end
end
