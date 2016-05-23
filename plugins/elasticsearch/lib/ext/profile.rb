require_dependency 'profile'
require_relative '../elasticsearch_indexed_model'

class Profile
  include ElasticsearchIndexedModel

  def self.control_fields
    [
      :visible,
      :public_profile,
    ]
  end
end
