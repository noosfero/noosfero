require_dependency 'person'
require_relative '../elasticsearch_indexed_model'

class Person
  include ElasticsearchIndexedModel

  def self.control_fields
    [
      :visible,
      :public_profile,
    ]
  end
end
