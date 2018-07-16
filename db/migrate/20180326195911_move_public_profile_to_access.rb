class MovePublicProfileToAccess < ActiveRecord::Migration
  def change
    execute('UPDATE profiles SET access = 25 WHERE public_profile = FALSE')
  end
end
