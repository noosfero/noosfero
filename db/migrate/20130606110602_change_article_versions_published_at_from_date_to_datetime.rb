class ChangeArticleVersionsPublishedAtFromDateToDatetime < ActiveRecord::Migration
  def self.up
    change_column :article_versions, :published_at, :datetime
  end

  def self.down
    change_column :article_versions, :published_at, :date
  end
end
