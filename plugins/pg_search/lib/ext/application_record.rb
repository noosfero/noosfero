require_dependency 'pg_search_plugin/search_scope'

searchables = %w[ article comment national_region profile license scrap category ]
searchables.each do |class_file|
  require_dependency class_file

  class_file.classify.constantize.class_eval do
    include PgSearchPlugin::SearchScope
  end
end
