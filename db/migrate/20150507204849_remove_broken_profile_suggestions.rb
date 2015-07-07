class RemoveBrokenProfileSuggestions < ActiveRecord::Migration
  def up
    execute("DELETE FROM profile_suggestions WHERE suggestion_id NOT IN (SELECT id from profiles)")
  end

  def down
    say "this migration can't be reverted"
  end
end
