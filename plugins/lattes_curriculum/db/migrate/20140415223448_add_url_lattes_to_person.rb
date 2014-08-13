class AddUrlLattesToPerson < ActiveRecord::Migration
  def self.up
  	add_column :profiles, :lattes_url, :string
  end

  def self.down
  	remove_column :profiles, :lattes_url
  end
end
