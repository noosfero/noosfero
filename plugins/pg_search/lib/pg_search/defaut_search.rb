searchables = %w[ article comment qualifier article national_region certifier profile license scrap category ]
searchables.each { |searchable| require_dependency searchable }
klasses = searchables.map {|searchable| searchable.camelize.constantize}

klasses.module_eval do
  include PgSearch
  pg_search_scope :pg_search_plugin_search, :against => SEARCHABLE_FIELDS
end
