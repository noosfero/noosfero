class RenameTagsBlockToTagsCloudBlock < ActiveRecord::Migration
  def change
    execute("UPDATE blocks SET type='TagsCloudBlock' WHERE type='TagsBlock'")
  end
end
