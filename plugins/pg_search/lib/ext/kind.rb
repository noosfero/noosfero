require_dependency 'kind'

Kind.class_eval do
  # Use count_without_distinct
  scope :pg_search_plugin_facets, -> scope {
    joins(:profiles).
    where('profiles.id' => scope.map(&:id)).
    group('kinds.id')
  }
end

