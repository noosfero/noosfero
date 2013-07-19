class ChangeArticlePublishedAtFromDateToDatetime < ActiveRecord::Migration
  def self.up
    change_column :articles, :published_at, :datetime
  end

  def self.down
    change_column :articles, :published_at, :date
  end
end
