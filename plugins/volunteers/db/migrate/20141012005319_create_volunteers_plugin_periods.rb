class CreateVolunteersPluginPeriods < ActiveRecord::Migration
  def up
    create_table :volunteers_plugin_periods do |t|
      t.integer :owner_id
      t.string :owner_type
      t.text :name
      t.datetime :start
      t.datetime :end
      t.integer :minimum_assigments
      t.integer :maximum_assigments

      t.timestamps
    end
    add_index :volunteers_plugin_periods, [:owner_type]
    add_index :volunteers_plugin_periods, [:owner_id, :owner_type]
  end

  def down
    drop_table :volunteers_plugin_periods
  end
end
