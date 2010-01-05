class FixPeopleWithoutNames < ActiveRecord::Migration
  def self.up
    select_all("SELECT name, identifier FROM profiles WHERE name = '' or name IS NULL").each do |profile|
      update("UPDATE profiles SET name = '%s' WHERE identifier = '%s'" % [profile['identifier'], profile['identifier']])
    end
  end

  def self.down
    say("Nothing to undo (cannot recover the data)")
  end
end
