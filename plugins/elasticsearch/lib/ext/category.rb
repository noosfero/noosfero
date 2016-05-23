require_dependency 'category'
require_relative '../elasticsearch_indexed_model'

class Category
  include ElasticsearchIndexedModel

  def self.control_fields
    []
  end

end
