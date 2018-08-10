class RemovePublicProfile < ActiveRecord::Migration
  def change
    remove_column :profiles, :public_profile
  end
end
