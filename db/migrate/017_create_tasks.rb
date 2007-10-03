class CreateTasks < ActiveRecord::Migration
  def self.up
    create_table :tasks do |t|
      t.column :description, :string

      t.column :data, :text
      t.column :status, :integer
      t.column :end_date, :date

      t.column :requestor_id, :integer
      t.column :target_id, :integer
    end
  end

  def self.down
    drop_table :tasks
  end
end
