class PgSearchPlugin < Noosfero::Plugin

  def self.plugin_name
    "Postgres Full-Text Search"
  end

  def self.plugin_description
    _("Search engine that uses Postgres Full-Text Search.")
  end

  def find_by_contents(asset, scope, query, paginate_options={}, options={})
    return if query.blank?
    {:results => scope.pg_search_plugin_search(query).paginate(paginate_options)}
  end

end
