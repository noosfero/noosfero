class AddResponsibleToTask < ActiveRecord::Migration

  def change
    add_column :tasks, :responsible_id, :integer
  end

end
