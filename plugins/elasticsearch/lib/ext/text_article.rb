# REQUIRE TO LOAD DESCENDANTS FROM TEXT_ARTICLE
require_dependency 'raw_html_article'
require_dependency 'tiny_mce_article'

require_dependency 'text_article'
require_relative '../elasticsearch_indexed_model'

class TextArticle
  def self.control_fields
    {
      :advertise => {},
      :published => {},
      :created_at => {type: 'date'}
    }
  end
  include ElasticsearchIndexedModel
end
