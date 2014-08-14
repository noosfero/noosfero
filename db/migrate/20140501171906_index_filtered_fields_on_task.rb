class IndexFilteredFieldsOnTask < ActiveRecord::Migration
  def self.up
    add_index :tasks, :requestor_id
    add_index :tasks, :target_id
    add_index :tasks, :target_type
    add_index :tasks, [:target_id, :target_type]
    add_index :tasks, :status
  end

  def self.down
    remove_index :tasks, :requestor_id
    remove_index :tasks, :target_id
    remove_index :tasks, :target_type
    remove_index :tasks, [:target_id, :target_type]
    remove_index :tasks, :status
  end
end
