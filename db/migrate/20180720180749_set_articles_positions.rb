class SetArticlesPositions < ActiveRecord::Migration
  def up
    Article.where(position: nil).update_all(position: 0)
  end

  def down
    say 'this migraiton cannot be reverted'
  end
end
