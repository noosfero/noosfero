require_dependency 'text_article'
require_relative '../elasticsearch_indexed_model'

class TextArticle
  include ElasticsearchIndexedModel

  def self.control_fields
    [
      :advertise,
      :published,
    ]
  end
end
