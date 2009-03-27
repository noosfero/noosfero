class CreateExternalFeeds < ActiveRecord::Migration
  def self.up
    create_table :external_feeds do |t|
      t.string     :feed_title
      t.date       :fetched_at
      t.string     :address
      t.integer    :blog_id,   :null => false
      t.boolean    :enabled,   :null => false, :default => true
      t.boolean    :only_once, :null => false, :default => true
      t.timestamps
    end
  end

  def self.down
    drop_table :external_feeds
  end
end
