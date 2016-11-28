require_dependency 'region'

Region.class_eval do
  # Use count_without_distinct
  scope :pg_search_plugin_facets, -> scope {
    joins(:profiles).
    where('profiles.id' => scope.map(&:id)).
    where('categories_profiles.virtual' => false).
    group('categories.id')
  }
end
