class SetPublicArticleIntoPublishedAttribute < ActiveRecord::Migration
  def self.up
    execute('update articles set published=(1!=1) where not public_article')
  end

  def self.down
    say "this migration can't be reverted"
  end
end
