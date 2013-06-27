require_dependency 'environment'

class Environment
  settings_items :solr_plugin_top_level_category_as_facet_ids, :type => Array, :default => []
end
