class AddClosedByToTask < ActiveRecord::Migration

  def change
    add_column :tasks, :closed_by_id, :integer
  end

end
