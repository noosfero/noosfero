class AddAccessToProfile < ActiveRecord::Migration[5.1]
  def change
    add_column :profiles, :access, :integer, default: 0
  end
end
