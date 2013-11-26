class AddSpamToTask < ActiveRecord::Migration
  def self.up
    change_table :tasks do |t|
      t.boolean :spam, :default => false
    end
    Task.update_all ["spam = ?", false]
    add_index :tasks, [:spam]
  end

  def self.down
    remove_column :tasks, :spam
  end
end
