class CreateProfileActivity < ActiveRecord::Migration
  def up
    ApplicationRecord.transaction do
      create_table :profile_activities do |t|
        t.integer :profile_id
        t.integer :activity_id
        t.string :activity_type
        t.timestamps
      end
      add_index :profile_activities, :profile_id
      add_index :profile_activities, [:activity_id, :activity_type]
      add_index :profile_activities, :activity_type

      Scrap.find_each batch_size: 50 do |scrap|
        scrap.send :create_activity
      end
      ActionTracker::Record.find_each batch_size: 50 do |action_tracker|
        action_tracker.send :create_activity
      end
    end
  end

  def down
    drop_table :profile_activities
  end
end
