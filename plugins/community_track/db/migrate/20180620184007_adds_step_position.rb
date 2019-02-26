class AddsStepPosition < ActiveRecord::Migration[5.1]
  def change
    add_column :articles, :step_position, :integer
  end
end
