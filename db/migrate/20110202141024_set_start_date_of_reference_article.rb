class SetStartDateOfReferenceArticle < ActiveRecord::Migration
  def self.up
    execute("SELECT articles.id as a_id, reference.start_date as r_start_date FROM articles INNER JOIN articles reference ON articles.reference_article_id = reference.id WHERE articles.Type = 'Event' AND articles.start_date IS NULL").each do |data|
      execute("UPDATE articles SET start_date = '#{data['r_start_date']}' WHERE id = #{data['a_id']}")
    end
  end

  def self.down
    say "Nothing to do"
  end
end
