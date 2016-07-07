# REQUIRE TO LOAD DESCENDANTS FROM TEXT_ARTICLE
require_dependency 'raw_html_article'
require_dependency 'tiny_mce_article'

require_dependency 'text_article'
require_relative '../elasticsearch_indexed_model'

class TextArticle

  def self.profile_hash
    {
      :id             => { type: :integer  },
      :visible        => { type: :boolean },
      :public_profile => { type: :boolean }
    }
  end


  def self.control_fields
    {
      :advertise => { type: :boolean },
      :published => { type: 'boolean'},
      :profile   => { type: :nested , hash: self.profile_hash }
    }
  end

  include ElasticsearchIndexedModel
end
