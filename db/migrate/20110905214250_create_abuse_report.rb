class CreateAbuseReport < ActiveRecord::Migration
  def self.up
    create_table :abuse_reports do |t|
      t.references  :reporter
      t.references  :abuse_complaint
      t.text        :content
      t.text        :reason
      t.timestamps
    end
  end

  def self.down
    drop_table :abuse_reports
  end
end
