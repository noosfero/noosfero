require_dependency 'comment'

class Comment
  after_save :solr_plugin_notify_article
  after_destroy :solr_plugin_notify_article

  def solr_plugin_notify_article
    article.solr_plugin_comments_updated if article.kind_of?(Article)
  end
end
