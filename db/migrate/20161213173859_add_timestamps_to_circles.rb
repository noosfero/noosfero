class AddTimestampsToCircles < ActiveRecord::Migration[4.2]
  def up
    add_column :circles, :created_at, :datetime
    add_column :circles, :updated_at, :datetime
  end

  def down
    remove_column :circles, :created_at
    remove_column :circles, :updated_at
  end
end
