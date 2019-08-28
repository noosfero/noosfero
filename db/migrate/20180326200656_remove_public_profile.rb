class RemovePublicProfile < ActiveRecord::Migration[4.2]
  def change
    remove_column :profiles, :public_profile
  end
end
