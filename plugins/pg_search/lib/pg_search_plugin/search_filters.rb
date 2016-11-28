require 'active_support/concern'

module PgSearchPlugin::SearchFilters
  extend ActiveSupport::Concern
  included do
    PgSearchPlugin::Filters.each do |name, table_name|
      scope "pg_search_plugin_by_#{name}", -> id {
        select("#{self.table_name}.id").
        joins(name.to_s.pluralize.to_sym).
        where("#{table_name}.id" => id)
      }
    end
  end
end
