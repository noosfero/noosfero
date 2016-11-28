require_dependency 'profile'
require_dependency 'pg_search_plugin/search_filters'

Profile.class_eval do
  PgSearchPlugin::Filters = {:tag => :tags, :category => :categories, :region => :categories, :kind => :kinds}
  include PgSearchPlugin::SearchFilters
end

