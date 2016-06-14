require_dependency 'person'
require_relative '../elasticsearch_indexed_model'

class Person
  def self.control_fields
    {
      :visible => {type: 'boolean'},
      :public_profile => {type: 'boolean'},
    }
  end
  include ElasticsearchIndexedModel
end
