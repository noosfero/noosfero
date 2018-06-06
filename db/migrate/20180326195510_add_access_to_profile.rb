class AddAccessToProfile < ActiveRecord::Migration
  def change
    add_column :profiles, :access, :integer, default: 0
  end
end
