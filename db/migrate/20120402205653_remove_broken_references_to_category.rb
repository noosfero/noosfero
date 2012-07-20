class RemoveBrokenReferencesToCategory < ActiveRecord::Migration
  def self.up
    execute <<-SQL
      delete from articles_categories where category_id not in (select id from categories);
    SQL
    execute <<-SQL
      delete from categories_profiles where category_id not in (select id from categories);
    SQL
  end

  def self.down
    say "this migration can't be reverted"
  end
end
