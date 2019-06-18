class RenameTagsBlockToTagsCloudBlock < ActiveRecord::Migration[4.2]
  def change
    execute("UPDATE blocks SET type='TagsCloudBlock' WHERE type='TagsBlock'")
  end
end
