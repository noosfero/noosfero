require_dependency 'article'
require_dependency 'pg_search_plugin/search_filters'

Article.class_eval do
  scope :pg_search_plugin_by_attribute, -> attribute, value { select('articles.id').where("articles.#{attribute}" => value) }

  PgSearchPlugin::Filters = {:tag => :tags, :category => :categories}
  include PgSearchPlugin::SearchFilters
end
