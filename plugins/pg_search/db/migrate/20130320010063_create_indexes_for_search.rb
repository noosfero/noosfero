class CreateIndexesForSearch < ActiveRecord::Migration
  SEARCHABLES = %w[ article comment qualifier national_region certifier profile license scrap category ]
  KLASSES = SEARCHABLES.map {|searchable| searchable.camelize.constantize }
  def self.up
    KLASSES.each do |klass|
      fields = klass.pg_search_plugin_fields
      execute "create index pg_search_plugin_#{klass.name.singularize.downcase} on #{klass.table_name} using gin(to_tsvector('simple', #{fields}))"
    end
  end

  def self.down
    KLASSES.each do |klass|
      execute "drop index pg_search_plugin_#{klass.name.singularize.downcase}"
    end
  end
end
