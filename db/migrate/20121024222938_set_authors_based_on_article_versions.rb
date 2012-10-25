class SetAuthorsBasedOnArticleVersions < ActiveRecord::Migration
  def self.up
    update('UPDATE articles SET author_id = (SELECT profiles.id FROM articles as a INNER JOIN article_versions ON a.id = article_versions.article_id INNER JOIN profiles ON profiles.id = article_versions.last_changed_by_id WHERE article_versions.version = 1 AND articles.id = a.id)')
  end

  def self.down
    say "Can not be revesed!"
  end
end
