require_dependency 'text_article'
require_relative '../elasticsearch_indexed_model'

class TextArticle
  def self.control_fields
    {
      :advertise => nil,
      :published => nil,
    }
  end
  include ElasticsearchIndexedModel
end
