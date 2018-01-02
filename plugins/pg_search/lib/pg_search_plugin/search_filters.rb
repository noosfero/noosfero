require 'active_support/concern'

module PgSearchPlugin::SearchFilters
  extend ActiveSupport::Concern
  included do
    PgSearchPlugin::Filters.each do |name, table_name|
      scope "pg_search_plugin_by_#{name}", -> id {
        select("#{self.table_name}.id")
        .joins(name.to_s.pluralize.to_sym)
        .where("#{table_name}.id" => id)
      }
    end

    PgSearchPlugin::CategoryFilters.each do |name, relation_table|
      scope "pg_search_plugin_by_#{name}", -> id {
        select("#{self.table_name}.id")
        .joins(name.to_s.pluralize.to_sym)
        .joins("INNER JOIN categories descendants "\
               "ON descendants.ancestry LIKE '%#{"%010d" % id}%' "\
               "OR descendants.id = #{id}")
        .where("#{relation_table}.category_id = descendants.id")
        .where("categories.id = descendants.id OR categories.id = #{id}")
      }
    end
  end
end
