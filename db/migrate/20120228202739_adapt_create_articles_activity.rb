class AdaptCreateArticlesActivity < ActiveRecord::Migration

  # Removing 'create_article' activities that grouped articles.
  # Creating new activities only to recent articles (not grouping)
  def self.up
    select_all("SELECT id FROM action_tracker WHERE verb = 'create_article'").each do |tracker|
      activity = ActionTracker::Record.find_by(id: tracker['id'])
      if activity
        activity.destroy
      end
    end

      select_all("SELECT id FROM articles").each do |art|
      article = Article.find(art['id'])
      if article && article.created_at >= 8.days.ago && article.author && article.author.kind_of?(Person)
        article.create_activity
      end
    end
  end

  def self.down
    say "this migration can't be reverted"
  end
end
