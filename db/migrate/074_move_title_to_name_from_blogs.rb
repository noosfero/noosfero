class MoveTitleToNameFromBlogs < ActiveRecord::Migration
  def self.up
    select_all("select id, setting from articles where type = 'Blog' and name != 'Blog'").each do |blog|
      title = YAML.load(blog['setting'])[:title]
      assignments = ApplicationRecord.sanitize_sql_for_assignment(:name => title)
      update("update articles set %s where id = %d" % [assignments, blog['id']] )
    end
  end

  def self.down
    say("Nothing to undo (cannot recover the data)")
  end
end
