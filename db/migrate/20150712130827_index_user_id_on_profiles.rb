class IndexUserIdOnProfiles < ActiveRecord::Migration

  def change
    add_index :profiles, :user_id
    add_index :profiles, [:user_id, :type]
  end

end
