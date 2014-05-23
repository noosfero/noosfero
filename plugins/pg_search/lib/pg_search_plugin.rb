class PgSearchPlugin < Noosfero::Plugin

  def self.plugin_name
    "Postgres Full-Text Search"
  end

  def self.plugin_description
    _("Search engine that uses Postgres Full-Text Search.")
  end

  def find_by_contents(asset, scope, query, paginate_options={}, options={})
    scope = scope.pg_search_plugin_search(query) unless query.blank?
    scope = scope.send(options[:filter]) if options[:filter]
    {:results => scope.paginate(paginate_options)}
  end

end
