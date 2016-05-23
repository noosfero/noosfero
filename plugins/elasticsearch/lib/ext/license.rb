require_dependency 'license.rb'
require_relative '../elasticsearch_indexed_model'

class License
  include ElasticsearchIndexedModel

  def self.control_fields
    []
  end
end
