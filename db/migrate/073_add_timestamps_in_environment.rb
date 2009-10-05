class AddTimestampsInEnvironment < ActiveRecord::Migration
  def self.up
    add_timestamps(:environments)
    execute "update environments set created_at = 'Thu Aug 06 14:07:04 -0300 2009'"
    execute 'update environments set updated_at = created_at'
  end

  def self.down
    remove_timestamps(:environments)
  end
end
