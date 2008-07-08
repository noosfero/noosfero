class UpdateRegionsToBecomeStatesAndCities < ActiveRecord::Migration
  def self.up
    execute "update categories set type = 'State' where parent_id in (select id from categories where type = 'Region' and parent_id in (select id from categories where type = 'Region' and name = 'Nacional'))"

    execute "update categories set type = 'City' where parent_id in (select id from categories where type = 'State')"
  end

  def self.down
    execute "update categories set type = 'Region' where type = 'State' or type = 'City'"
  end
end
