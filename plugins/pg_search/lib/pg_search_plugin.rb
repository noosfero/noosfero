lib_path = File.join(File.dirname(__FILE__), 'pg_search', 'lib')
ActiveSupport::Dependencies.load_paths << lib_path
$: << lib_path
require 'pg_search'

class PgSearchPlugin < Noosfero::Plugin

  def self.plugin_name
    "Postgres Full-Text Search"
  end

  def self.plugin_description
    _("Search engine that uses Postgres Full-Text Search.")
  end

  def find_by_contents(asset, scope, query, paginate_options={}, options={})
    scope.pg_search_plugin_search(query)
  end

end

searchables = %w[ article comment qualifier national_region certifier profile license scrap category ]
searchables.each { |searchable| require_dependency searchable }
klasses = searchables.map {|searchable| searchable.camelize.constantize }

klasses.each do |klass|
  klass.class_eval do
    include PgSearch
    pg_search_scope :pg_search_plugin_search, :against => klass::SEARCHABLE_FIELDS
  end
end
