class AddTimestampsToTags < ActiveRecord::Migration[4.2]
  def change
    add_timestamps :tags
    execute("UPDATE tags SET created_at = now(), updated_at = now()")
  end
end
