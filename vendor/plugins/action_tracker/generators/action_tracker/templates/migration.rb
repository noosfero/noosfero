class CreateActionTracker < ActiveRecord::Migration
  def self.up
    create_table :action_tracker do |t|
      t.belongs_to :user, :polymorphic => true
      t.belongs_to :dispatcher, :polymorphic => true
      t.text :params
      t.string :verb
      t.timestamps
    end

    change_table :action_tracker do |t|
      t.index [:user_id, :user_type]
      t.index [:dispatcher_id, :dispatcher_type]
      t.index :verb
    end
  end

  def self.down
    drop_table :action_tracker
  end
end
