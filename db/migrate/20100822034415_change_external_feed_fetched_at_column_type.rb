class ChangeExternalFeedFetchedAtColumnType < ActiveRecord::Migration
  def self.up
    change_table :external_feeds do |t|
      t.change :fetched_at, :datetime
    end
  end

  def self.down
    change_table :external_feeds do |t|
      t.change :fetched_at, :date
    end
  end
end
