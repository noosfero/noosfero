class AddsStepPosition < ActiveRecord::Migration
  def change
    add_column :articles, :step_position, :integer
  end
end
