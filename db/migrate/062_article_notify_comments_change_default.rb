class ArticleNotifyCommentsChangeDefault < ActiveRecord::Migration
  def self.up
    change_column_default :articles, :notify_comments, true
  end

  def self.down
    change_column_default :articles, :notify_comments, false
  end
end
