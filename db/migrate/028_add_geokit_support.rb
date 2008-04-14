class AddGeokitSupport < ActiveRecord::Migration

  TABLES = [ :profiles, :categories ]

  def self.up
    TABLES.each do |table|
      add_column table, :lat, :float
      add_column table, :lng, :float
    end
    add_column :profiles, :geocode_precision, :integer
  end

  def self.down
    TABLES.each do |t|
      remove_column t, :lat
      remove_column t, :lng
    end
    remove_column :profiles, :geocode_precision
  end
end
