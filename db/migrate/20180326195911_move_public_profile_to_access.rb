class MovePublicProfileToAccess < ActiveRecord::Migration[4.2]
  def change
    execute("UPDATE profiles SET access = 20 WHERE public_profile = FALSE")
  end
end
