class RemoveStepPosition < ActiveRecord::Migration
  def change
    remove_column :articles, :step_position
  end
end
