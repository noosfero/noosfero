class AddThemeAttribute < ActiveRecord::Migration
  TABLE = [ :profiles, :environments ]

  def self.up
    TABLE.each do |table|
      add_column table, :theme, :string
    end
  end

  def self.down
    TABLE.each do |table|
      remove_column table, :theme
    end
  end
end
