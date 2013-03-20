class CreateIndexesForSearch < ActiveRecord::Migration
  def self.up
    searchables = %w[ article comment qualifier national_region certifier profile license scrap category ]
    klasses = searchables.map {|searchable| searchable.camelize.constantize }
    klasses.each do |klass|
      klass::SEARCHABLE_FIELDS.keys.each do |field|
        execute "create index pg_search_plugin_#{klass.name.singularize.downcase}_#{field} on #{klass.table_name} using gin(to_tsvector('simple', \"#{klass.table_name}\".#{field}))"
      end
    end
  end

  def self.down
    klasses.each do |klass|
      klass::SEARCHABLE_FIELDS.keys.each do |field|
        execute "drop index pg_search_plugin_#{klass.name.singularize.downcase}_#{field}"
      end
    end
  end
end
