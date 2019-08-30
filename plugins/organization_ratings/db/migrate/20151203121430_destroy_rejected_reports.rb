class DestroyRejectedReports < ActiveRecord::Migration[5.1]
  def up
    comments = []
    select_all("SELECT data FROM tasks WHERE type = 'CreateOrganizationRatingComment' AND status = 2").each do |task|
      settings = YAML.load(task["data"])
      comments << settings[:organization_rating_comment_id]
    end
    if !comments.empty?
      execute("DELETE FROM comments WHERE id IN (#{comments.join(',')})")
    end
  end

  def down
    say "This migration can't be reverted"
  end
end
