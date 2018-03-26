require_dependency 'profile'
require_dependency 'pg_search_plugin/search_filters'

Profile.class_eval do
  def self.pg_search_plugin_filters
    {:tag => :tags, :category => :categories, :region => :categories, :kind => :kinds}
  end

  include PgSearchPlugin::SearchFilters
end
