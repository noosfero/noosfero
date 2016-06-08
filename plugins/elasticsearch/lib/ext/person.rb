require_dependency 'person'
require_relative '../elasticsearch_indexed_model'

class Person
  def self.control_fields
    [
      :visible,
      :public_profile,
    ]
  end
  include ElasticsearchIndexedModel
end
