class CreateReports < ActiveRecord::Migration
  def self.up
    create_table :spaminator_plugin_reports do |t|
      t.integer     :spams_by_content, :default => 0
      t.integer     :spams_by_no_network, :default => 0
      t.integer     :spammers_by_comments, :default => 0
      t.integer     :spammers_by_no_network, :default => 0
      t.integer     :total_people, :default => 0
      t.integer     :total_comments, :default => 0
      t.integer     :processed_comments, :default => 0
      t.integer     :processed_people, :default => 0
      t.references  :environment
      t.text        :failed
      t.timestamps
    end
  end

  def self.down
    drop_table :spaminator_plugin_reports
  end
end
