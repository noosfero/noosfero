require_dependency 'article'

class Article

  # search for interests of interested that matches the knowledges of wise
  scope :sniffer_plugin_knowledges_interests, lambda { |wise, interested|
    {
     :select => "op.opportunity_id AS interest_cat,
                articles.name AS knowledge_name, articles.id AS id,
                article_resources.resource_id AS knowledge_cat",
      :joins => "INNER JOIN article_resources ON (articles.id = article_resources.article_id)
                INNER JOIN sniffer_plugin_opportunities AS op ON (article_resources.resource_id = op.opportunity_id
                      AND article_resources.resource_type = 'ProductCategory' AND op.opportunity_type = 'ProductCategory')
                INNER JOIN sniffer_plugin_profiles sniffer ON (op.profile_id = sniffer.id AND sniffer.enabled = true)",
      :conditions => "articles.type = 'CmsLearningPlugin::Learning'
                AND articles.profile_id = #{wise.id}
                AND sniffer.profile_id = #{interested.id}"
    }
  }
end
