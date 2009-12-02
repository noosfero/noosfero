class RenameLocationBlock < ActiveRecord::Migration
  def self.up
    execute "update blocks set type='LocationBlock' where type='LocalizationBlock'"
  end

  def self.down
    execute "update blocks set type='LocalizationBlock' where type='LocationBlock'"
  end
end
