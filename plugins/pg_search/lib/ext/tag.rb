require_dependency 'tag'

Tag.class_eval do
  # Use count_without_distinct
  scope :pg_search_plugin_facets, -> scope {
    joins(:taggings).
    where('taggings.taggable_id' => scope.map(&:id)).
    where("taggings.taggable_type = '#{scope.base_class.name}'").
    where("taggings.context = 'tags'").
    where('taggings.tagger_id IS NULL').
    group('tags.id')
  }
end
