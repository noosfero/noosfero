require_dependency 'article'

class Article
  def solr_plugin_comments_updated
    solr_save
  end
end
