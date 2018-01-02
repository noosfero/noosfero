require_dependency 'region'

Region.class_eval do
  # Use count_without_distinct
  scope :pg_search_plugin_profiles_facets, -> scope {
    facets_for_klass(:profiles, scope)
  }

  scope :pg_search_plugin_articles_facets, -> scope {
    facets_for_klass(:articles, scope)
  }
end
