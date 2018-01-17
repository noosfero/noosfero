require_dependency 'profile'
require_dependency 'pg_search_plugin/search_filters'

Profile.class_eval do
  PgSearchPlugin::Filters = { :tag => :tags, :kind => :kinds }
  PgSearchPlugin::CategoryFilters = { category: 'categories_profiles', region: 'categories_profiles' }
  include PgSearchPlugin::SearchFilters
end

