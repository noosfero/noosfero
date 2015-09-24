class CreateVolunteersPluginAssignments < ActiveRecord::Migration
  def up
    create_table :volunteers_plugin_assignments do |t|
      t.integer :profile_id
      t.integer :period_id

      t.timestamps
    end
    add_index :volunteers_plugin_assignments, [:period_id]
    add_index :volunteers_plugin_assignments, [:profile_id]
    add_index :volunteers_plugin_assignments, [:profile_id, :period_id]
  end

  def down
    drop_table :volunteers_plugin_assignments
  end
end
