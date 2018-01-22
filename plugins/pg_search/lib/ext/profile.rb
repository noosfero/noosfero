require_dependency 'profile'
require_dependency 'pg_search_plugin/search_filters'

Profile.class_eval do
  def self.pg_search_plugin_filters
    { :tag => :tags, :kind => :kinds }
  end

  def self.pg_search_plugin_category_filters
    { category: 'categories_profiles', region: 'categories_profiles' }
  end

  include PgSearchPlugin::SearchFilters
end

