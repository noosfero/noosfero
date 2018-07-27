class SetArticlesPositions < ActiveRecord::Migration[5.1]
  def up
    Article.where(position: nil).update_all(position: 0)
  end

  def down
    say 'this migration cannot be reverted'
  end
end
