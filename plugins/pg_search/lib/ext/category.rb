require_dependency 'category'

Category.class_eval do
  # Use count_without_distinct
  scope :pg_search_plugin_profiles_facets, -> scope {
    facets_for_klass(:profiles, scope).
    where("categories.type IS NULL OR categories.type = 'Category'")
  }

  scope :pg_search_plugin_articles_facets, -> scope {
    facets_for_klass(:articles, scope).
    where("categories.type IS NULL OR categories.type = 'Category'")
  }

  private

  def self.facets_for_klass(klass, scope)
    joins(klass.to_sym).
    where("#{klass}.id" => scope.ids).
    group('categories.id')
  end

end
