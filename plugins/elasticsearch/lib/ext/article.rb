require_dependency 'article'
require_relative '../elasticsearch_indexed_model'

class Article
  include ElasticsearchIndexedModel

  def self.control_fields
    [
      :advertise,
      :published,
    ]
  end
end
