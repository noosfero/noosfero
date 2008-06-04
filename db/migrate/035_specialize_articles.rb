class SpecializeArticles < ActiveRecord::Migration
  def self.up
    execute "update articles set type = 'TinyMceArticle' where type = 'Article' or type is null or type = ''"
  end

  def self.down
    # nothing
  end
end
