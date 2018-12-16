class RemoveStepPosition < ActiveRecord::Migration[5.1]
  def change
    remove_column :articles, :step_position
  end
end
