class AddGoogleMapsKeyToDomain < ActiveRecord::Migration

  def self.up
    add_column :domains, :google_maps_key, :string
  end

  def self.down
    remove_column :domains, :google_maps_key
  end

end
