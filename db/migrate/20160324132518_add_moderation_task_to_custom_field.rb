class AddModerationTaskToCustomField < ActiveRecord::Migration
  def up
    add_column :custom_fields, :moderation_task, :boolean, :default => false
  end

  def down
    remove_column :custom_fields, :moderation_task
  end
end
